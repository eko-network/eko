create table "public"."devices" (
  "id" uuid not null default gen_random_uuid(),
  "created_at" timestamp with time zone not null default now(),
  "uid" uuid default gen_random_uuid(),
  "session_id" uuid default gen_random_uuid(),
  "signer_public_key" bytea not null
);

create table "public"."key_packages" (
  "id" uuid not null default gen_random_uuid(),
  "device_id" uuid not null,
  "key_package" bytea not null
);

CREATE OR REPLACE FUNCTION public.custom_access_token_hook (event jsonb) RETURNS jsonb LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  original_claims jsonb := event -> 'claims';
  device_did      uuid;
  claim           text;
  new_claims      jsonb;
BEGIN
  -- look up did by session_id
  SELECT id INTO device_did
  FROM public.devices
  WHERE session_id = (original_claims ->> 'session_id')::uuid;

  -- start from original claims, only add did if device is registered
  new_claims := original_claims;

  IF device_did IS NOT NULL THEN
    new_claims := jsonb_set(new_claims, '{did}', to_jsonb(device_did));
  END IF;

  RETURN jsonb_build_object('claims', new_claims);
END;
$$;

CREATE OR REPLACE FUNCTION public.register_device (p_did UUID, p_signer_public_key TEXT DEFAULT NULL) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  v_uid        UUID := auth.uid();
  v_session_id UUID := (auth.jwt() ->> 'session_id')::UUID;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  INSERT INTO public.devices (id, uid, session_id, signer_public_key)
  VALUES (
    p_did, 
    v_uid, 
    v_session_id,  
    CASE WHEN p_signer_public_key IS NOT NULL THEN decode(p_signer_public_key, 'base64') ELSE NULL END
  )
  ON CONFLICT (id) DO UPDATE
    SET session_id        = EXCLUDED.session_id,
        signer_public_key   = COALESCE(EXCLUDED.signer_public_key, public.devices.signer_public_key),
        created_at          = now()
  WHERE public.devices.uid = v_uid;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Device id % is registered to a different user', p_did;
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

CREATE OR REPLACE FUNCTION public.take_key_package (p_device_id UUID) RETURNS BYTEA LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
    v_ids UUID[];
    v_packages BYTEA[];
BEGIN
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
