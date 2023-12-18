import os
import tempfile
import shutil

from flask import current_app

import bpkipy
from .openssl import openssl

bpki_path = os.getcwd()  # + "/../../"
out_path = '/out'


def dvcs_req(req):
    serial = 1234
    tmpdirname = tempfile.mkdtemp()
    try:
        data = bpkipy.dvcs_extract_data(req)
        with open(f"{tmpdirname}/dvcs_data.der", "wb") as f:
            f.write(data)
        current_app.logger.debug(f"File is saved to: {tmpdirname}/dvcs_data.der")
        cmd = (f"cms -verify -CAfile {out_path}/ca1/chain "
               f" -in {tmpdirname}/dvcs_data.der -inform der -purpose any")
        retcode, block, er__ = openssl(cmd)
        if retcode == 1:
            resp = bpkipy.dvcs_cert_info(req, serial)
        else:
            resp = bpkipy.dvcs_error_notice(status=2, error_list=['Verification failure.'])
    except Exception as e:
        current_app.logger.error('DVCS: ' + str(e))
        error_list = [str(e)]
        resp = bpkipy.dvcs_error_notice(
            status=2, error_list=error_list
        )

    with open(f"{tmpdirname}/response", 'wb') as rf:
        rf.write(resp)
    cmd = (f"cms -sign -in {tmpdirname}/response "
           f"-signer {out_path}/dvcs/cert "
           f"-inkey {out_path}/dvcs/privkey -passin pass:dvcsdvcsdvcs "
           f"-binary -econtent_type id-smime-ct-DVCSResponseData -cades "
           f"-out {tmpdirname}/signed_response.der -outform der -nodetach -nosmimecap ")
    _, out_, err_ = openssl(cmd)
    with open(f"{tmpdirname}/signed_response.der", 'rb') as rf:
        result = rf.read()

    shutil.rmtree(tmpdirname)
    return result
