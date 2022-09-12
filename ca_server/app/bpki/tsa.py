import os
import tempfile
import shutil

from flask import current_app

from .openssl import openssl


def tsa_req(req, no_nonce=True):
    tmpdirname = tempfile.mkdtemp()
    with open(f"{tmpdirname}/req.tsq", "wb") as f:
        f.write(req)
    current_app.logger.debug(f"File is saved to: {tmpdirname}/req1.tsq")
    cmd = (f"ts -reply -queryfile {tmpdirname}/req.tsq -signer ./out/tsa/cert"
           " -passin pass:tsatsatsa -inkey ./out/tsa/privkey"
           f" -out {tmpdirname}/resp.tsr")
    if no_nonce:
        cmd = cmd + " -no_nonce"
    current_app.logger.debug(cmd)
    retcode, block, er__ = openssl(cmd)
    current_app.logger.debug(er__)
    with open(f"{tmpdirname}/resp.tsr", "rb") as f:
        data = f.read()
    current_app.logger.debug(f"File is read from: {tmpdirname}/resp.tsr")
    shutil.rmtree(tmpdirname)
    return data
