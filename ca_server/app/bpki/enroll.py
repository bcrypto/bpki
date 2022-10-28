import os
import re
import tempfile
import shutil
import datetime

from flask import current_app

from .openssl import openssl
from .req import Req

bpki_path = os.getcwd()  # + "/../../"
out_path = bpki_path + '/out'
enroll1_path = out_path + '/enroll1/'


class Enroll1(Req):
    def __init__(self, message, tmp_name, days=365):
        super().__init__(message, tmp_name)
        self.days = days
        self.cert = None
        self.serial = None
        self.enveloped_cert = None
        self.e_pwd = None
        self.info_pwd = None
        # TODO: add req_id checking for duplicated requests

    # convert from CSR(%1)-DER to CSR(%1)-PEM
    def extract_csr(self):
        cmd = (f"req -in {self.path}/verified_csr.der -inform der "
               f"-out {self.path}/csr -outform pem ")
        _, out_, err_ = openssl(cmd)

    # extracting Cert(signer of Signed(CSR(%1)))
    def extract_cert(self):
        # call decode out/%1/verified_cert_opra > nul
        pass

    # validating Cert(signer of Signed(CSR(%1))).CertificatePolicies
    def validate_cert_pol(self):
        cmd = f"x509 -in {self.path}/verified_cert_opra -text -noout"
        _, out_, err_ = openssl(cmd)
        current_app.logger.debug(out_.decode("utf-8").find('bpki-role-ra'))

    # processing CSR(%1).challengePassword
    def process_csr_chall_pwd(self):
        cmd = (f"req -in {self.path}/csr "
               f"-inform pem -text -noout")
        _, out_, err_ = openssl(cmd)
        out_ = out_.decode("utf-8")
        res = re.search(r"challengePassword.*(\n)?", out_)
        if res:
            res = res.group(0)
            challenge_pwd = res.split(':', maxsplit=1)[1].strip()
            res_info_pwd = re.search(r"/INFO([^\\/])*", challenge_pwd)
            if res_info_pwd:
                info_pwd = res_info_pwd.group(0).split(':')[1]
                self.info_pwd = info_pwd
            # res_e_pwd = re.search(r"/EPWD([^/])*", challenge_pwd)
            # if res_e_pwd:
            #    e_pwd = res_e_pwd.group(0).split(':')[1]
            #    self.e_pwd = e_pwd

    # creating Cert(%1)
    def create_cert(self):
        cmd = (f"ca -name ca1 -batch -in {self.path}/csr "
               f"-key ca1ca1ca1 -days {self.days} "
               # f"-extfile ./cfg/{self.path}.cfg -extensions exts"
               f"-out {self.path}/tmp_cert -notext -utf8 ")
        _, out_, err_ = openssl(cmd)
        # Extract serial number from certificate
        cmd = f"x509 -noout -serial -in {self.path}/tmp_cert"
        _, out_, err_ = openssl(cmd)
        self.serial = bytes.fromhex(out_.decode("utf-8").strip().split('=')[1])
        cmd = f"x509 -outform der -in {self.path}/tmp_cert -out {self.path}/tmp_cert.der"
        _, out_, err_ = openssl(cmd)
        with open(f"{self.path}/tmp_cert.der", "rb") as f:
            cert = f.read()
        self.cert = cert

    # enveloping Cert(%1) for opRA
    def envelope_cert(self, recip_cert=None):
        if recip_cert is None:
            recip_cert = f"{self.path}/tmp_cert"
        cmd = (
            f"cms -encrypt -in {self.path}/tmp_cert.der -binary -inform der "
            f"-recip {recip_cert} -belt-ctr256 "
            f"-out {self.path}/enveloped_cert.der -outform der ")
        _, out_, err_ = openssl(cmd)
        with open(f"{self.path}/enveloped_cert.der", "rb") as f:
            self.enveloped_cert = f.read()

    def reg_data(self):
        # Extract serial number from certificate
        cmd = f"x509 -noout -dates -in {self.path}/tmp_cert"
        _, out_, err_ = openssl(cmd)

        def str_date(s):      # Oct  6 11:05:08 2023 GMT
            return datetime.datetime.strptime(s, "%b %d %H:%M:%S %Y GMT")

        dates = {k.strip(): str_date(v) for i in out_.decode("utf-8").strip().split('\n') for k, v in [i.split('=')]}
        current_app.logger.debug(dates)
        return [
            self.serial,
            self.info_pwd,
            bytes.fromhex(self.req_id),
            self.cert,
            dates['notBefore'],
            dates['notAfter']
        ]
