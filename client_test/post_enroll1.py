import requests
import argparse

r = requests.post('http://127.0.0.1:5000/bpki/enroll1', data={'key': 'value'})
print(r.status_code)
print(r.text)

