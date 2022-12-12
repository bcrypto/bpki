import os
import tempfile
import shutil

from flask import current_app

from .openssl import openssl

bpki_path = os.getcwd()  # + "/../../"
out_path = bpki_path + '/out'
enroll1_path = out_path + '/enroll1/'


class Req:
    def __init__(self, message, tmp_name):
        self.path = tempfile.mkdtemp()
        with open(f"{self.path}/{tmp_name}", 'wb') as f:
            f.write(message)
        cmd = f"dgst -belt-hash {self.path}/{tmp_name}"
        _, id_, err_ = openssl(cmd)
        id_ = id_.decode("utf-8").split('=')[1].strip()
        self.req_id = id_
        current_app.logger.debug(self.req_id)
        self.signer_cert_file = None

    def __del(self):
        shutil.rmtree(self.path)

    # recovering Enveloped(Signed(CSR(%1)))
    def decrypt(self, input_name, output_name):
        cmd = (f"cms -decrypt -in {self.path}/{input_name} -inform der "
               f"-inkey {out_path}/ca1/privkey -out {self.path}/{output_name} "
               f"-outform der -binary -passin pass:ca1ca1ca1 -debug_decrypt")
        ret, out_, err_ = openssl(cmd)
        current_app.logger.debug(f"cms-decrypt return code: {ret}")
        if ret > 1:
            raise Exception("Decrypt error: " + err_.decode("utf-8"))

    # verifying Signed(CSR(%1)) and extract message
    def verify(self, input_name, output_name):
        cmd = (f"cms -verify -in {self.path}/{input_name} -inform der "
               f"-CAfile {out_path}/ca1/chain "
               f"-signer {self.path}/cert "
               f"-out {self.path}/{output_name} -outform der -purpose any")
        ret, out_, err_ = openssl(cmd)
        current_app.logger.debug(f"cms-verify return code: {ret}")
        if ret > 1:
            raise Exception("Verification error: " + err_.decode("utf-8"))
        self.signer_cert_file = f"{self.path}/cert"
        cmd = (f"verify -CRLfile {out_path}/current_crl1 -crl_check "
               f"-CAfile {out_path}/ca1/chain "
               f"{self.path}/cert ")
        ret, out_, err_ = openssl(cmd)
        current_app.logger.debug(f"verify return code: {ret}")
        if ret > 1:
            raise Exception("Signer certificate had been revoked.")

    def convert_format(self, inputfile, outputfile, to="pem"):
        if to == "pem":
            cmd = (f"pkcs7 -in out/{self.req_id}/{inputfile} -inform der "
                   f"-out out/{self.req_id}/{outputfile} -outform pem")
            openssl(cmd)
        elif to == "der":
            cmd = (f"pkcs7 -in out/{self.req_id}/{inputfile} -inform pem "
                   f"-out out/{self.req_id}/{outputfile} -outform der")
            openssl(cmd)

    # sign response
    def sign_response(self, response):
        with open(f"{self.path}/response", 'wb') as rf:
            rf.write(response)
        cmd = (f"cms -sign -in {self.path}/response "
               f"-signer {out_path}/agca1/cert "
               f"-inkey {out_path}/agca1/privkey -passin pass:agca1agca1agca1 "
               f"-binary -econtent_type bpki-ct-resp "
               f"-out {self.path}/signed_response.der -outform der -nodetach -nosmimecap ")
        _, out_, err_ = openssl(cmd)
        with open(f"{self.path}/signed_response.der", 'rb') as rf:
            resp = rf.read()
        return resp

    # revoke for Reenroll process
    def revoke_cert(self):
        cmd = (f"ca -revoke {self.path}/cert -name ca1 -key ca1ca1ca1"
               f" -crl_reason superseded ")
        openssl(cmd)
        cmd = (f"ca -gencrl -name ca1 -key ca1ca1ca1 -crldays 1 -crlhours 6 "
               f" -crlexts crlexts -out {out_path}/current_crl1 -batch")
        openssl(cmd)
