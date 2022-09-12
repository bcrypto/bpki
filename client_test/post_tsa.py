import requests
import base64
import os

if not os.path.exists("answers/tsa"):
    os.mkdir("answers/tsa")

print("-- 2 TSA Response1 --------------------")
with open("out/tsa/req1.tsq", "rb") as f:
    req = f.read()
req_str = base64.b64encode(req)
r = requests.post('http://127.0.0.1:5000/bpki/tsa', data=req_str)
print(r.status_code)
print(r.text)
with open("answers/tsa/resp1.tsr", "wb") as f:
    f.write(base64.b64decode(r.text))
print(" stored in answers/tsa/resp1.tsr")

print(" -- 5 TSA Response2 --------------------")
with open("out/tsa/req2.tsq", "rb") as f:
    req = f.read()
req_str = base64.b64encode(req)
r = requests.post('http://127.0.0.1:5000/bpki/tsa2', data=req_str)
print(r.status_code)
print(r.text)
with open("answers/tsa/resp2.tsr", "wb") as f:
    f.write(base64.b64decode(r.text))
print(" stored in answers/tsa/resp2.tsr")
