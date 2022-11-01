import os
import tempfile
import shutil

from flask import current_app

from .openssl import openssl

bpki_path = os.getcwd()  # + "/../../"
out_path = bpki_path + '/out'


def ocsp_req(req):
    tmpdirname = tempfile.mkdtemp()
    with open(f"{tmpdirname}/ocsp_req.der", "wb") as f:
        f.write(req)
    current_app.logger.debug(f"File is saved to: {tmpdirname}/ocsp_req.der")
    # ocsp -index out/ca1/index.txt -CA out/ca1/cert ^
    #  -rsigner out/ocsp/cert -rkey out/ocsp/privkey_plain ^
    #  -reqin out/ocsp/req1.der -respout out/ocsp/resp1.der -resp_no_certs
    cmd = (f"ocsp -index out/ca1/index.txt -CA {out_path}/ca1/cert"
           f" -rsigner {out_path}/ocsp/cert -rkey {out_path}/ocsp/privkey_plain "
           f" -reqin {tmpdirname}/ocsp_req.der -respout {tmpdirname}/ocsp_resp.der -resp_no_certs")
    retcode, block, er__ = openssl(cmd)
    with open(f"{tmpdirname}/ocsp_resp.der", "rb") as f:
        data = f.read()
    current_app.logger.debug(f"File is read from: {tmpdirname}/ocsp_resp.der")
    shutil.rmtree(tmpdirname)
    return data
