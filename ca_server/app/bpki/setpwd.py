from flask import current_app

from .openssl import openssl
from .req import Req


class SetPwd(Req):
    def __init__(self, message, tmp_name):
        super().__init__(message, tmp_name)
        self.cert = None
        self.serial = None
        self.password = None

    # recovering ASN1 UTF8String
    def parse(self, input_name):
        cmd = f"asn1parse -in {self.path}/{input_name} -inform der"
        _, out_, err_ = openssl(cmd)
        # current_app.logger.debug(out_)
        password = out_.decode('utf-8').split(':', 3)[-1].strip()
        # current_app.logger.debug(password)
        if password.startswith("/RPWD:"):
            self.password = password[6:]
        else:
            raise Exception('Password is not started with RPWD: prefix.')
        # current_app.logger.debug(self.password)
