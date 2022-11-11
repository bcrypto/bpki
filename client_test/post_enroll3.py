import requests
import base64
import os
import sys
from config import HOSTNAME

entity = sys.argv[1]

if not os.path.exists(f"answers/{entity}"):
    os.mkdir(f"answers/{entity}")

print(f"-- Enroll3 Processing on server {entity}")
with open(f"out/{entity}/enveloped_csr.der", "rb") as f:
    req = f.read()
req_str = base64.b64encode(req.strip())
r = requests.post(f'http://{HOSTNAME}/bpki/enroll3', data=req_str)
print(r.status_code)
print(r.text)
with open(f"answers/{entity}/enveloped3_cert.der", "wb") as f:
    f.write(base64.b64decode(r.text))
print(f" stored in answers/{entity}/enveloped3_cert.der")
