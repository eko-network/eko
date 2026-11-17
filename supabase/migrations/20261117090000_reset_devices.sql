-- for a user who lost every approved device: drops all their devices and
-- registers the calling one as trusted on first use, starting a new device
-- chain, which their contacts are warned about. The user has to have just
-- confirmed an emailed code, which shows as an otp entry in the token's amr claim
CREATE OR REPLACE FUNCTION public.reset_devices (
  p_did UUID,
  p_signer_public_key TEXT,
  p_key_packages TEXT[],
  p_last_resort_key_package TEXT,
  p_chain_entry JSONB,
  p_chain_hash TEXT
) RETURNS UUID LANGUAGE plpgsql SECURITY DEFINER
SET
  search_path = '' AS $$
DECLARE
  v_uid UUID := auth.uid();
BEGIN
  IF v_uid IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM jsonb_array_elements(COALESCE(auth.jwt() -> 'amr', '[]'::jsonb)) AS m
    WHERE m ->> 'method' = 'otp'
      AND (m ->> 'timestamp')::BIGINT > extract(epoch FROM now() - interval '10 minutes')
  ) THEN
    RAISE EXCEPTION 'Resetting devices needs a recently confirmed email code';
  END IF;

  PERFORM pg_advisory_xact_lock(hashtextextended(v_uid::text, 0));
  DELETE FROM public.devices WHERE uid = v_uid;

  RETURN public.register_device(
    p_did,
    p_signer_public_key,
    p_key_packages,
    p_last_resort_key_package,
    p_chain_entry,
    p_chain_hash
  );
END;
$$;
