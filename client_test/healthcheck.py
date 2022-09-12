import requests

print("== Testing OpenSSL healthcheck ============================================")
r = requests.get('http://127.0.0.1:5000/bpki/healthcheck')
print(r.status_code)
print(r.text)
