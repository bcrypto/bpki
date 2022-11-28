import requests
import base64
import os
import sys
import bpkipy
from config import HOSTNAME

entity = sys.argv[1]

if not os.path.exists(f"answers/{entity}"):
    os.mkdir(f"answers/{entity}")

with open(f"out/{entity}/signed_csr.der", "rb") as f:
    dvcs_data = f.read()
dvcs_req = bpkipy.dvcs_request(dvcs_data)
req_str = base64.b64encode(dvcs_req)
r = requests.post(f'http://{HOSTNAME}/bpki/dvcs', data=req_str)
print(r.status_code)
print(r.text)
with open(f"answers/{entity}/dvcs_resp.der", "wb") as f:
    f.write(base64.b64decode(r.text))
print(f" stored in answers/{entity}/dvcs_resp.der")
