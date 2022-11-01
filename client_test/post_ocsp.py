import requests
import base64
import os
import sys
from config import HOSTNAME

entity = sys.argv[1]

if not os.path.exists(f"answers/{entity}"):
    os.mkdir(f"answers/{entity}")

print(f"-- 2 OCSP Response1 for Cert({entity})---------")
with open(f"out/{entity}/ocsp_req.der", "rb") as f:
    req = f.read()
req_str = base64.b64encode(req.strip())
r = requests.post(f'http://{HOSTNAME}/bpki/ocsp', data=req_str)
print(r.status_code)
print(r.text)
with open(f"answers/{entity}/ocsp_resp.der", "wb") as f:
    f.write(base64.b64decode(r.text))
print(f" stored in answers/{entity}/ocsp_resp.der")
