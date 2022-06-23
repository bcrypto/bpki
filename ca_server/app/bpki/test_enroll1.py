import sys

# setting path
from openssl import openssl
from enroll import Req, Enroll1
import os
from os.path import expanduser
home = expanduser("~")
bpki_path = os.getcwd() + "/../../"
out_path = bpki_path + 'out'

with open(f"{out_path}/fnp/enveloped_signed_csr", 'r') as f:
    data = f.read()

user1 = Enroll1(file=data, req_dir=f"{out_path}/fnp2")
user1.recover()
user1.verify()
user1.extract_csr()
user1.validate_cert_pol()
user1.process_csr_chall_pwd()
user1.create_cert()
user1.envelope_cert()

