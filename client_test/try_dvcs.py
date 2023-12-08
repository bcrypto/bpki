import requests
import base64
import os
import sys
import bpkipy
from config import HOSTNAME

filepath = sys.argv[1]

with open(f"{filepath}", "rb") as f:
    dvcs_data = f.read()
dvcs_req = bpkipy.dvcs_request(dvcs_data)
with open(f"{filepath}_req.der", "wb") as f:
    f.write(dvcs_req)
print(f"Request stored in {filepath}_req.der")
req_str = base64.b64encode(dvcs_req)
r = requests.post(f'http://{HOSTNAME}/bpki/dvcs', data=req_str)
print(r.status_code)
print(r.text)
with open(f"{filepath}_resp.der", "wb") as f:
    f.write(base64.b64decode(r.text))
print(f"Response stored in {filepath}_resp.der")