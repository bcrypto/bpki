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

    # revoke certificate
    def revoke(self, cert=None):
        if cert is not None:
            with open(f"{self.path}/cert.der", 'wb') as f:
                f.write(cert)
            cmd = f"x509 -outform pem -in {self.path}/cert.der -out {self.path}/cert"
            _, out_, err_ = openssl(cmd)
        reason = {
            1: "keyCompromise",
            2: "cACompromise",
            3: "affiliationChanged",
            4: "superseded",
            5: "cessationOfOperation",
            6: "certificateHold",
            8: "removeFromCRL",
            9: "privilegeWithdrawn",
            10: "aACompromise"
        }
        options = {
            1: f"-crl_compromise {self.rev_data['date']}",

        }
        crl_reason = reason.get(self.rev_data['reason'], "unspecified")
        custom_option = options.get(self.rev_data['reason'], "")
        "-crl_compromise {time}"
        cmd = (f"ca -revoke {self.path}/cert -name ca1 -key ca1ca1ca1"
               f" -crl_reason {crl_reason} {custom_option} ")
        openssl(cmd)
