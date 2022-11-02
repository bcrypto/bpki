import requests
from config import HOSTNAME

r = requests.get(f'http://{HOSTNAME}/bpki/crl')
print(r.status_code)
with open(f"answers/crl.der", "wb") as f:
    f.write(r.content)
print(f" stored in answers/crl.der")
