# Eko Messenger Integration
- [x] Add auth hook to insert a custom claim into the JWT.

- [ ] Generate a UUID that persists through logouts to identify the device, add this to the JWT instead of the integer device ID. I think device ID instead of the ecp session based did will be better for MLS. Maybe integrate this with existing notification code?

- [ ] Either update ecp-dart-sdk or reorganize into a separate dart package in this repo. Wrap a Rust MLS implementation.

- [ ] Rework JWT verification in Rust server and update type signatures for the new key bundles. I think changes to API should be minimal.
