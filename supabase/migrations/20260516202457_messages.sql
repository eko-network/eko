create table "public"."devices" (
  "id" uuid not null default gen_random_uuid(),
  "created_at" timestamp with time zone not null default now(),
  "uid" uuid default gen_random_uuid(),
  "session_id" uuid default gen_random_uuid(),
  "signer_public_key" bytea not null,
  "approved_at" timestamp with time zone default null
);

create policy "Enable users to view their own data only" on "public"."devices" as permissive for
select
  to authenticated using (
    (
      (
        SELECT
          auth.uid () AS uid
      ) = uid
    )
  );

-- Signed AddDevice/RevokeDevice entries forming each user's device hash chain.
-- Clients sign and verify the entries, the server only stores them in order
-- and keeps them in step with approved_at, so it cannot add a device clients
-- would accept. hash is the client computed hash of the entry, what the next
-- entry's prev has to match.
create table "public"."device_chain" (
  "uid" uuid not null,
  "seq" integer not null,
  "entry" jsonb not null,
  "hash" bytea not null
);

alter table "public"."device_chain" enable row level security;

alter table "public"."device_chain"
add constraint "device_chain_pkey" PRIMARY KEY (uid, seq);

alter table "public"."device_chain"
add constraint "device_chain_uid_fkey" FOREIGN KEY (uid) REFERENCES public.users (id) ON UPDATE CASCADE ON DELETE CASCADE;

grant all on table "public"."device_chain" to "service_role";

-- appends an entry signed by the calling device on top of the user's chain,
-- concurrent appends on the same head fail instead of forking the chain
CREATE OR REPLACE FUNCTION public.append_device_chain (
  p_uid UUID,
  p_caller_did UUID,
  p_entry JSONB,
  p_hash TEXT
) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  v_seq  INTEGER;
  v_hash BYTEA;
BEGIN
  PERFORM pg_advisory_xact_lock(hashtextextended(p_uid::text, 0));

  SELECT seq, hash INTO v_seq, v_hash
  FROM public.device_chain
  WHERE uid = p_uid
  ORDER BY seq DESC
  LIMIT 1;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'User % has no device chain', p_uid;
  END IF;

  IF p_entry ->> 'prev' IS DISTINCT FROM encode(v_hash, 'base64') THEN
    RAISE EXCEPTION 'Device chain entry does not extend the current head';
  END IF;

  IF p_entry ->> 'signer' IS DISTINCT FROM p_caller_did::text THEN
    RAISE EXCEPTION 'Device chain entry is not signed by the calling device';
  END IF;

  INSERT INTO public.device_chain (uid, seq, entry, hash)
  VALUES (p_uid, v_seq + 1, p_entry, decode(p_hash, 'base64'));
END;
$$;

REVOKE ALL ON FUNCTION public.append_device_chain (UUID, UUID, JSONB, TEXT)
FROM
  PUBLIC,
  anon,
  authenticated;

-- approval has to come from a different, already approved device of the same user
-- p_entry is the AddDevice chain entry for it, signed by the calling device
CREATE OR REPLACE FUNCTION public.approve_device (did uuid, p_entry jsonb, p_hash text) RETURNS void LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  v_uid        UUID := auth.uid();
  v_caller_did UUID := NULLIF(auth.jwt() -> 'app_metadata' ->> 'did', '')::UUID;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF v_caller_did IS NULL OR v_caller_did = approve_device.did THEN
    RAISE EXCEPTION 'A device cannot approve itself';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.devices
    WHERE id = v_caller_did AND uid = v_uid AND approved_at IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Calling device is not approved';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.devices
    WHERE id = approve_device.did
      AND uid = v_uid
      AND approved_at IS NULL
      AND p_entry ->> 'type' = 'AddDevice'
      AND p_entry ->> 'did' = approve_device.did::text
      AND decode(p_entry ->> 'identityKey', 'base64') = signer_public_key
  ) THEN
    RAISE EXCEPTION 'No pending device matches the chain entry';
  END IF;

  PERFORM public.append_device_chain(v_uid, v_caller_did, p_entry, p_hash);

  UPDATE public.devices
  SET approved_at = now()
  WHERE id = approve_device.did
    AND uid = v_uid;
END;
$$;

create table "public"."key_packages" (
  "id" uuid not null default gen_random_uuid(),
  "device_id" uuid not null,
  "key_package" bytea not null
);

CREATE OR REPLACE FUNCTION public.custom_access_token_hook (event jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  approved_at_v timestamp with time zone;
  original_claims jsonb := event -> 'claims';
  device_did      uuid;
  claim           text;
  new_claims      jsonb;
BEGIN
  -- look up did by session_id
  SELECT id, approved_at INTO device_did, approved_at_v
  FROM public.devices
  WHERE session_id = (original_claims ->> 'session_id')::uuid;

  -- start from original claims, only add did if device is registered
  new_claims := original_claims;

  IF device_did IS NOT NULL THEN
    new_claims := jsonb_set(new_claims, '{app_metadata, did}', to_jsonb(device_did));
  END IF;

  IF approved_at_v IS NOT NULL THEN
    new_claims := jsonb_set(new_claims, '{app_metadata, dat}', to_jsonb(approved_at_v));
  END IF;

  RETURN jsonb_build_object('claims', new_claims);
END;
$$;

-- re-registering a device id from a different session drops its approval and key packages.
-- p_chain_entry is the device's self-signed AddDevice entry, used when it is
-- trusted on first use and so starts a new device chain for the user
CREATE OR REPLACE FUNCTION public.register_device (
  p_did UUID,
  p_signer_public_key TEXT DEFAULT NULL,
  p_key_packages TEXT[] DEFAULT NULL,
  p_chain_entry JSONB DEFAULT NULL,
  p_chain_hash TEXT DEFAULT NULL
) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  v_uid        UUID := auth.uid();
  v_session_id UUID := (auth.jwt() ->> 'session_id')::UUID;
  v_tofu BOOL;
  pkg          TEXT;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  -- the device being re-registered counts too, otherwise taking over the only
  -- approved device id would be trusted on first use
  SELECT NOT EXISTS (
    SELECT 1 FROM public.devices
    WHERE uid = v_uid AND approved_at IS NOT NULL
  ) INTO v_tofu;

  -- no device is left to vouch for the old chain, so it is replaced, which
  -- other users' clients see as the user's devices being reset
  IF v_tofu THEN
    IF p_chain_entry IS NULL
      OR p_chain_entry ->> 'type' IS DISTINCT FROM 'AddDevice'
      OR p_chain_entry ->> 'did' IS DISTINCT FROM p_did::text
      OR p_chain_entry ->> 'signer' IS DISTINCT FROM p_did::text
      OR p_chain_entry ->> 'prev' IS NOT NULL
      OR p_chain_entry ->> 'identityKey' IS DISTINCT FROM p_signer_public_key
    THEN
      RAISE EXCEPTION 'A first device needs a self-signed device chain entry';
    END IF;

    PERFORM pg_advisory_xact_lock(hashtextextended(v_uid::text, 0));
    DELETE FROM public.device_chain WHERE uid = v_uid;
    INSERT INTO public.device_chain (uid, seq, entry, hash)
    VALUES (v_uid, 0, p_chain_entry, decode(p_chain_hash, 'base64'));
  END IF;

  DELETE FROM public.key_packages
  WHERE device_id = p_did
    AND EXISTS (
      SELECT 1 FROM public.devices
      WHERE id = p_did AND uid = v_uid AND session_id IS DISTINCT FROM v_session_id
    );

  INSERT INTO public.devices (id, uid, session_id, signer_public_key, approved_at)
  VALUES (
    p_did,
    v_uid,
    v_session_id,
    CASE WHEN p_signer_public_key IS NOT NULL THEN decode(p_signer_public_key, 'base64') ELSE NULL END,
    CASE WHEN v_tofu THEN now() ELSE NULL END
  )
  ON CONFLICT (id) DO UPDATE
    SET session_id          = EXCLUDED.session_id,
        signer_public_key   = COALESCE(EXCLUDED.signer_public_key, public.devices.signer_public_key),
        approved_at         = CASE
                                WHEN public.devices.session_id IS NOT DISTINCT FROM EXCLUDED.session_id
                                  THEN public.devices.approved_at
                                ELSE EXCLUDED.approved_at
                              END,
        created_at          = now()
  WHERE public.devices.uid = v_uid;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Device id % is registered to a different user', p_did;
  END IF;

  IF p_key_packages IS NOT NULL AND array_length(p_key_packages, 1) > 0 THEN
    FOREACH pkg IN ARRAY p_key_packages LOOP
      INSERT INTO public.key_packages (device_id, key_package)
      VALUES (p_did, decode(pkg, 'base64'));
    END LOOP;
  END IF;

  RETURN p_did;
END;
$$;

CREATE OR REPLACE FUNCTION public.add_key_packages (p_did UUID, p_key_packages TEXT[]) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  v_uid UUID := auth.uid();
  pkg   TEXT;          
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM public.devices WHERE id = p_did AND uid = v_uid
  ) THEN
    RAISE EXCEPTION 'Device % does not belong to the authenticated user', p_did;
  END IF;

  FOREACH pkg IN ARRAY p_key_packages LOOP
    INSERT INTO public.key_packages (device_id, key_package)
    VALUES (p_did, decode(pkg, 'base64'));
  END LOOP;
END;
$$;

-- a device can always remove itself (sign out), removing another requires an approved caller.
-- p_entry is the RevokeDevice chain entry, signed by the calling device, and
-- is required for a device in the chain, it is null for a pending one
CREATE OR REPLACE FUNCTION public.remove_device (
  p_did UUID,
  p_entry JSONB DEFAULT NULL,
  p_hash TEXT DEFAULT NULL
) RETURNS VOID LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  v_uid        UUID := auth.uid();
  v_caller_did UUID := NULLIF(auth.jwt() -> 'app_metadata' ->> 'did', '')::UUID;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF v_caller_did IS DISTINCT FROM p_did AND NOT EXISTS (
    SELECT 1 FROM public.devices
    WHERE id = v_caller_did AND uid = v_uid AND approved_at IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Calling device is not approved';
  END IF;

  IF p_entry IS NOT NULL THEN
    IF p_entry ->> 'type' IS DISTINCT FROM 'RevokeDevice'
      OR p_entry ->> 'did' IS DISTINCT FROM p_did::text
    THEN
      RAISE EXCEPTION 'Chain entry does not revoke device %', p_did;
    END IF;
    PERFORM public.append_device_chain(v_uid, v_caller_did, p_entry, p_hash);
  ELSIF EXISTS (
    SELECT 1 FROM public.devices
    WHERE id = p_did AND uid = v_uid AND approved_at IS NOT NULL
  ) THEN
    RAISE EXCEPTION 'Removing an approved device needs a chain entry';
  END IF;

  DELETE FROM public.devices WHERE id = p_did AND uid = v_uid;
END;
$$;

-- pending devices must not be added to groups
CREATE OR REPLACE FUNCTION public.take_key_package (p_device_id UUID) RETURNS BYTEA LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
    v_ids UUID[];
    v_packages BYTEA[];
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM public.devices
        WHERE id = p_device_id AND approved_at IS NOT NULL
    ) THEN
        RAISE EXCEPTION 'Device % is not approved', p_device_id;
    END IF;

    SELECT array_agg(id), array_agg(key_package)
    INTO v_ids, v_packages
    FROM (
        SELECT id, key_package
        FROM public.key_packages
        WHERE device_id = p_device_id
        LIMIT 2
        FOR UPDATE
    ) locked_rows;

    IF v_ids IS NULL THEN
        RAISE EXCEPTION 'No key packages available for device %', p_device_id;
    END IF;

    IF array_length(v_ids, 1) > 1 THEN
        DELETE FROM public.key_packages WHERE id = v_ids[1];
    END IF;

    RETURN v_packages[1];
END;
$$;

CREATE OR REPLACE FUNCTION public.ensure_pending_approval (did UUID) RETURNS BOOL LANGUAGE sql
SET
  search_path = '' AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.devices
    WHERE id = did
      AND approved_at IS NULL
  );
$$;

alter table "public"."devices" enable row level security;

CREATE UNIQUE INDEX devices_pkey ON public.devices USING btree (id);

alter table "public"."devices"
add constraint "devices_pkey" PRIMARY KEY using index "devices_pkey";

alter table "public"."devices"
add constraint "devices_uid_fkey" FOREIGN KEY (uid) REFERENCES public.users (id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."devices" validate constraint "devices_uid_fkey";

set
  check_function_bodies = off;

grant delete on table "public"."devices" to "anon";

grant insert on table "public"."devices" to "anon";

grant references on table "public"."devices" to "anon";

grant
select
  on table "public"."devices" to "anon";

grant trigger on table "public"."devices" to "anon";

grant
truncate on table "public"."devices" to "anon";

grant
update on table "public"."devices" to "anon";

grant delete on table "public"."devices" to "authenticated";

grant insert on table "public"."devices" to "authenticated";

grant references on table "public"."devices" to "authenticated";

grant
select
  on table "public"."devices" to "authenticated";

grant trigger on table "public"."devices" to "authenticated";

grant
truncate on table "public"."devices" to "authenticated";

grant
update on table "public"."devices" to "authenticated";

grant delete on table "public"."devices" to "service_role";

grant insert on table "public"."devices" to "service_role";

grant references on table "public"."devices" to "service_role";

grant
select
  on table "public"."devices" to "service_role";

grant trigger on table "public"."devices" to "service_role";

grant
truncate on table "public"."devices" to "service_role";

grant
update on table "public"."devices" to "service_role";

alter table "public"."key_packages" enable row level security;

CREATE UNIQUE INDEX key_packages_pkey ON public.key_packages USING btree (id);

CREATE INDEX key_packages_device_id_idx ON public.key_packages USING btree (device_id);

alter table "public"."key_packages"
add constraint "key_packages_pkey" PRIMARY KEY using index "key_packages_pkey";

alter table "public"."key_packages"
add constraint "key_packages_device_id_fkey" FOREIGN KEY (device_id) REFERENCES public.devices (id) ON UPDATE CASCADE ON DELETE CASCADE not valid;

alter table "public"."key_packages" validate constraint "key_packages_device_id_fkey";

grant delete on table "public"."key_packages" to "authenticated";

grant insert on table "public"."key_packages" to "authenticated";

grant references on table "public"."key_packages" to "authenticated";

grant
select
  on table "public"."key_packages" to "authenticated";

grant trigger on table "public"."key_packages" to "authenticated";

grant
truncate on table "public"."key_packages" to "authenticated";

grant
update on table "public"."key_packages" to "authenticated";

grant delete on table "public"."key_packages" to "service_role";

grant insert on table "public"."key_packages" to "service_role";

grant references on table "public"."key_packages" to "service_role";

grant
select
  on table "public"."key_packages" to "service_role";

grant trigger on table "public"."key_packages" to "service_role";

grant
truncate on table "public"."key_packages" to "service_role";

grant
update on table "public"."key_packages" to "service_role";
