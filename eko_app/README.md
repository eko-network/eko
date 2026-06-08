# eko

# Developing
### Setup
In order to develop with eko-messenger, you need the following setup:
1. Clone ecp-dart-sdk one directory above `eko/`
2. Clone eko-messenger
3. Clone eko

### Running `eko-messenger` server
Start the db
```
devenv up
```

and run the app with
```
cargo run -p eko
```

The environment variables are set in flake.nix.

### Running `eko` 
Start the local supabase
```
supabase start
```

On first launch or when the db changes, you need to apply the migrations with
```
supabase db refresh
```

Then launch the app with
```
./eko_app/run_dev
```

The environment variables for the db should be copied from what is printed when you run `supabase start` and put in `./.env`
```
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_PUBLISHABLE_KEY=sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH
```
