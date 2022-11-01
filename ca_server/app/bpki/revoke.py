import os
import datetime

from flask import current_app

from .openssl import openssl
from .req import Req
import bpkipy

bpki_path = os.getcwd()  # + "/../../"
out_path = bpki_path + '/out'
enroll1_path = out_path + '/revoke/'


class Revoke(Req):
    def __init__(self, message, tmp_name):
        super().__init__(message, tmp_name)
        self.cert = None
        self.serial = None
        self.rev_data = None

    # recovering Enveloped(Signed(RevReq(%1)))
    def parse(self, input_name):
        with open(f"{self.path}/{input_name}", "rb") as f:
            rev_req = f.read()
        self.rev_data = bpkipy.parse_revoke(rev_req)
        current_app.logger.debug(self.rev_data)

    # verifying Signed(RevReq(%1))
    def revoke_cert(self):
        cmd = (f"cms -verify -in {self.path}/recovered_signed_csr -inform der "
               f"-CAfile {out_path}/ca1/chain "
               f"-signer {out_path}/opra/cert "
               f"-out {self.path}/verified_csr.der -outform der -purpose any")
        _, out_, err_ = openssl(cmd)

    def revoke(self, cert, crl_reason):
        with open(f"{self.path}/cert", 'wb') as f:
            f.write(cert)
            # ca -revoke out/opra/cert0 -name ca1 -key ca1ca1ca1 \
            #   -crl_reason keyCompromise -crl_compromise $ldt -batch
        custom_option = ""
        "-crl_compromise {time}"
        cmd = (f"ca -revoke {self.path}/cert -name ca1 -key ca1ca1ca1"
               f" -crl_reason {crl_reason} {custom_option} -batch")
        openssl(cmd)
