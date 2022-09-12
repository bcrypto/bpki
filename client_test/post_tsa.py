import requests
import base64

with open("out/tsa/req1.tsq", "rb") as f:
    req = f.read()
req_str = base64.b64encode(req)
r = requests.post('http://127.0.0.1:5000/bpki/tsa', data=req_str)
print(r.status_code)
print(r.text)
