import requests
import base64
from config import HOSTNAME

with open(f"out/dvcs/dvcs_req.der", "rb") as f:
    dvcs_req = f.read()
req_str = base64.b64encode(dvcs_req)
r = requests.post(f'http://{HOSTNAME}/bpki/dvcs', data=req_str)
print(r.status_code)
print(r.text)
with open(f"answers/dvcs_resp.der", "wb") as f:
    f.write(base64.b64decode(r.text))
print(f" stored in answers/dvcs_resp.der")
