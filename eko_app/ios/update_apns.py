#!/usr/bin/env python3
import json
import base64
import sys
import re

if len(sys.argv) < 2:
    print("Usage: update_apns.py <byte_array> [group_id_byte_array]")
    print("Example: update_apns.py '[0, 1, 0, 2, ...]' '[47, 98, ...]'")
    sys.exit(1)

bytes_list = json.loads(sys.argv[1])
mls_bytes = bytes(bytes_list)
encoded = base64.b64encode(mls_bytes).decode()

group_id = sys.argv[2] if len(sys.argv) > 2 else None

if group_id is not None:
    group_bytes = bytes(json.loads(group_id))
    group_encoded = base64.b64encode(group_bytes).decode()

with open("test_push.apns", "r") as f:
    content = f.read()

apns = json.loads(content)
apns["mls_message"] = encoded
if group_id is not None:
    apns["group_id"] = group_encoded

with open("test_push.apns", "w") as f:
    json.dump(apns, f, indent=2)
    f.write("\n")

print(f"Updated test_push.apns with mls_message ({len(encoded)} chars)")
if group_id is not None:
    print(f"  and group_id ({len(group_encoded)} chars)")
