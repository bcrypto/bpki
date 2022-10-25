import requests
import base64
import os
import sys

entity = sys.argv[1]

if not os.path.exists(f"answers/{entity}"):
    os.mkdir(f"answers/{entity}")

print(f"-- 2 Processing Revoke on server {entity}")
with open(f"out/{entity}/revoke.der", "rb") as f:
    req = f.read()
req_str = base64.b64encode(req.strip())
r = requests.post('http://127.0.0.1:5000/bpki/revoke', data=req_str)
print(r.status_code)
print(r.text)
with open(f"answers/{entity}/rev_resp.der", "wb") as f:
    f.write(base64.b64decode(r.text))
print(f" stored in answers/{entity}/rev_resp.der")