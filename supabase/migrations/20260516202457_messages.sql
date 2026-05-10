create table "public"."devices" (
  "id" uuid not null default gen_random_uuid(),
  "created_at" timestamp with time zone not null default now(),
  "uid" uuid default gen_random_uuid(),
  "session_id" uuid default gen_random_uuid()
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

CREATE OR REPLACE FUNCTION public.register_device (p_did UUID) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  v_uid        UUID := auth.uid();
  v_session_id UUID := (auth.jwt() ->> 'session_id')::UUID;
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  INSERT INTO public.devices (id, uid, session_id)
  VALUES (p_did, v_uid, v_session_id)
  ON CONFLICT (id) DO UPDATE
    SET session_id = EXCLUDED.session_id,
        created_at  = now()
  WHERE public.devices.uid = v_uid;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Device id % is registered to a different user', p_did;
  END IF;

  RETURN p_did;
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
