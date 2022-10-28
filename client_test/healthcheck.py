import requests
from config import HOSTNAME

print("== Testing OpenSSL healthcheck ============================================")
r = requests.get(f'http://{HOSTNAME}/bpki/healthcheck')
print(r.status_code)
print(r.text)
