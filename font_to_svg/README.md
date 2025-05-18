### Font to Svg
Put all the fonts you want uploaded in the `fonts/` folder.

The script will generate and upload all svgs, enumerated, to the database. It will overwrite any svgs already in `eko_logos`

##### Setup
Download the secrets json from firebase, and put the path in `firebase_storage.py`

##### Running
```bash
uv run main.py
```
