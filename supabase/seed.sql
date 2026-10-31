-- Local development accounts, loaded by `supabase db reset` (see [db.seed] in config.toml).
-- Every account signs in with the password "password".
--
--   alice@test.local   a11ce000-0000-4000-8000-000000000001
--   bob@test.local     b0b00000-0000-4000-8000-000000000002
--   carol@test.local   ca201000-0000-4000-8000-000000000003

WITH accounts (id, email, username, name) AS (
  VALUES
    ('a11ce000-0000-4000-8000-000000000001'::uuid, 'alice@test.local', 'alice', 'Alice'),
    ('b0b00000-0000-4000-8000-000000000002'::uuid, 'bob@test.local', 'bob', 'Bob'),
    ('ca201000-0000-4000-8000-000000000003'::uuid, 'carol@test.local', 'carol', 'Carol')
),
new_users AS (
  -- handle_new_user creates the public.users profile from raw_user_meta_data
  INSERT INTO auth.users (
    instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
    raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
    -- GoTrue fails to scan NULL into these, so they have to be empty strings
    confirmation_token, recovery_token, email_change, email_change_token_new,
    email_change_token_current, phone_change, phone_change_token, reauthentication_token
  )
  SELECT
    '00000000-0000-0000-0000-000000000000', id, 'authenticated', 'authenticated', email,
    extensions.crypt('password', extensions.gen_salt('bf')), now(),
    '{"provider": "email", "providers": ["email"]}',
    jsonb_build_object(
      'username', username, 'name', name, 'birthday', '2000-01-01',
      'bio', '', 'is_verified', false
    ),
    now(), now(),
    '', '', '', '', '', '', '', ''
  FROM accounts
  RETURNING id, email
)
INSERT INTO auth.identities (provider_id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at)
SELECT
  id::text, id,
  jsonb_build_object('sub', id::text, 'email', email, 'email_verified', true),
  'email', now(), now(), now()
FROM new_users;
