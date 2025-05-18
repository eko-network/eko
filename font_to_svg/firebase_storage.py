# /// script
# requires-python = ">=3.12"
# dependencies = [
#     "firebase-admin",
# ]
# ///
import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage
import os

cred = credentials.Certificate("untitled-2832f-firebase-adminsdk-ci4f0-4c04f70d05.json")
firebase_admin.initialize_app(cred, {"storageBucket": "untitled-2832f.appspot.com"})
bucket = storage.bucket()


def upload_files_from_directory(input_dir: str, upload_dir: str):
    svg_files = [f for f in os.listdir(input_dir) if f.endswith(".svg")]
    svg_files.sort()

    for index, filename in enumerate(svg_files, start=1):
        local_file_path = os.path.join(input_dir, filename)
        destination_blob_path = f"{upload_dir}/{index}.svg"

        blob = bucket.blob(destination_blob_path)
        blob.upload_from_filename(local_file_path)

        print(f"Uploaded {filename} as {destination_blob_path}")
