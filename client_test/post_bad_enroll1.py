import requests
import base64

rev_req = bytes.fromhex(
    "306d30223113301106035504030c0a425920526f6f74204341310b30090603550406130242"
    "5902144aa374ded08626a19e46ecad2b32c1c7de8b04970c0f5265766f6b655f5061737377"
    "6f72640a0103180f31393835313130363231303632375a0c0c6e6f626f6479206b6e6f7773"
)
req_str = base64.b64encode(rev_req)
r = requests.post('http://127.0.0.1:5000/bpki/enroll1', data=req_str)
print(r.status_code)
print(r.text)
with open(f"answers/bpki_resp.der", "wb") as f:
    f.write(base64.b64decode(r.text))
print(f" stored in answers/bpki_resp.der")
