import requests
from config import HOSTNAME

r = requests.get(f'http://{HOSTNAME}/bpki/crl1')
print(r.status_code)
with open(f"answers/crl1.der", "wb") as f:
    f.write(r.content)
print(f" stored in answers/crl1.der")
