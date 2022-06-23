from app.openssl import openssl
import os
from os.path import expanduser

home = expanduser("~")
bpki_path = os.getcwd() + '/app/bpki/'
out_path = bpki_path + 'out/'
tsa_path = out_path + 'tsa/'


def tsa_req(file_, hash='bash256', nonce=True):
    if not nonce:
        cmd = (f'ts -query -data {file_} -{hash}'
               '-out ./out/tsa/req.tsq -no_nonce')
    else:
        cmd = f'ts -query -data {file_} -{hash} -out ./out/tsa/req.tsq -cert'
    retcode, block, er__ = openssl(cmd)
    print(file_, hash, nonce, os.getcwd())
    print(er__)
    cmd = (f"ts -reply -queryfile ./out/tsa/req.tsq -signer ./out/tsa/cert"
           "-passin pass:tsatsatsa -inkey ./out/tsa/privkey"
           "-out ./out/tsa/resp.tsr -no_nonce")
    retcode, block, er__ = openssl(cmd)
    print(er__)
    return retcode
