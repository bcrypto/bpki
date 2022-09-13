import os
import re
import tempfile
import shutil

from flask import current_app

from .openssl import openssl

bpki_path = os.getcwd()  # + "/../../"
out_path = bpki_path + '/out'
enroll1_path = out_path + '/enroll1/'


class Req:
    def __init__(self, file, days_=365):
        self.days = days_
        self.path = tempfile.mkdtemp()
        with open(f"{self.path}/enveloped_signed_csr", 'wb') as f:
            f.write(file)
        cmd = f"dgst -belt-hash {self.path}/enveloped_signed_csr"
        _, id_, err_ = openssl(cmd)
        current_app.logger.debug(err_)
        current_app.logger.debug(id_)
        id_ = id_.decode("utf-8").split('=')[1].strip()
        self.req_id = id_
        current_app.logger.debug(self.req_id)

    def __del(self):
        shutil.rmtree(self.path)

    def recover_enveloped(self, container, out):
        cmd = (f"cms -decrypt -in {self.path}/{container} -inform der"
               f"-inkey {out_path}/ca1/privkey -out {self.path}/{out}"
               f"-binary -passin pass:ca1ca1ca1 -debug_decrypt")
        openssl(cmd)

    def convert_format(self, inputfile, outputfile, to="pem"):
        if to == "pem":
            cmd = (f"pkcs7 -in out/{self.req_id}/{inputfile} -inform der"
                   f"-out out/{self.req_id}/{outputfile} -outform pem")
            openssl(cmd)
        elif to == "der":
            cmd = (f"pkcs7 -in out/{self.req_id}/{inputfile} -inform pem"
                   f"-out out/{self.req_id}/{outputfile} -outform der")
            openssl(cmd)


class Enroll1(Req):
    def __init__(self, file, days=365):
        super().__init__(file, days)
        self.cert = None
        self.enveloped_cert = None
        self.e_pwd = None
        self.info_pwd = None

    # recovering Enveloped(Signed(CSR(%1)))
    def recover(self):
        cmd = (
            f"cms -decrypt -in {self.path}/enveloped_signed_csr -inform der "
            f"-inkey {out_path}/ca1/privkey -out {self.path}/recovered_signed_csr "
            f"-outform der -binary -passin pass:ca1ca1ca1 -debug_decrypt")
        _, out_, err_ = openssl(cmd)

    # verifying Signed(CSR(%1))
    def verify(self):
        cmd = (f"cms -verify -in {self.path}/recovered_signed_csr -inform der "
               f"-CAfile {out_path}/ca1/chain "
               f"-signer {out_path}/opra/cert "
               f"-out {self.path}/verified_csr.der -outform der -purpose any")
        _, out_, err_ = openssl(cmd)

    # extracting CSR(%1) from Signed(CSR(%1))
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
               f"-inform der -text -noout")
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
            res_e_pwd = re.search(r"/EPWD([^/])*", challenge_pwd)
            if res_e_pwd:
                e_pwd = res_e_pwd.group(0).split(':')[1]
                self.e_pwd = e_pwd

    # creating Cert(%1)
    def create_cert(self):
        cmd = (f"ca -name ca1 -batch -in {self.path}/csr "
               f"-key ca1ca1ca1 -days {self.days} "
               # f"-extfile ./cfg/{self.path}.cfg -extensions exts"
               f"-out {self.path}/tmp_cert -notext -utf8 ")
        _, out_, err_ = openssl(cmd)
        cmd = f"x509 -outform der -in {self.path}/tmp_cert -out {self.path}/tmp_cert.der"
        _, out_, err_ = openssl(cmd)
        with open(f"{self.path}/tmp_cert.der", "rb") as f:
            cert = f.read()
        self.cert = cert

    # enveloping Cert(%1) for opRA
    def envelope_cert(self):
        cmd = (
            f"cms -encrypt -in {self.path}/tmp_cert.der -binary -inform der "
            f"-recip {out_path}/opra/cert -belt-ctr256 "
            f"-out {self.path}/enveloped_cert.der -outform der ")
        _, out_, err_ = openssl(cmd)
        with open(f"{self.path}/enveloped_cert.der", "rb") as f:
            self.enveloped_cert = f.read()

    # recovering Enveloped(Cert(%1))
    def recover_env_cert(self):
        cmd = (
            f"openssl cms -decrypt -in {self.path}/enveloped_cert -inform pem "
            f"-inkey {out_path}/opra/privkey -out {self.path}/cert.der -outform der "
            f"-passin pass:opraopraopra -debug_decrypt")
        openssl(cmd)

        cmd = (f"openssl x509 -in {self.path}/cert.der "
               f"-inform der -out {self.path}/cert -outform pem")
        openssl(cmd)
