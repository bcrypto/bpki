from flask import Blueprint, render_template, request, send_file
from . import tsa as tsa_
import base64
import re
import os
from os.path import expanduser
from .enroll import Enroll1
# from enroll import Enroll1
import tempfile, shutil
from app import db
from app.user.models import Certificate

home = expanduser("~")
bpki_path = os.getcwd() + '/app/bpki/'
out_path = bpki_path + 'out/'
enroll1_path = out_path + 'enroll1/'

bpki_bp = Blueprint('bpki_bp', __name__,
                    template_folder='../templates',
                    static_folder='../static')

counter = 0

@bpki_bp.route('/bpki', methods=['GET'])
def bpki():
    return render_template('bpki.html')


@bpki_bp.route('/bpki/tsa', methods=['GET'])
def tsa():
    file_ = request.args.get('file', type=str).strip()
    hash_ = request.args.get('hash', type=str).strip()
    nonce_ = request.args.get('nonce', type=str).strip()
    tsa_.tsa_req(file_, hash_, nonce_ == 'True')
    return send_file('/flask_app/out/tsa/resp.tsr')

@bpki_bp.route('/bpki/ocsp', methods=['GET'])
def ocsp():
    pass


@bpki_bp.route('/bpki/enroll1', methods=['POST'])
def enroll1():
    data = request.get_data()
    req = base64.b64decode(data)
    tmpdirname = tempfile.mkdtemp()
    proc = Enroll1(file=req, req_dir=tmpdirname)
    proc.recover()
    proc.verify()
    proc.extract_csr()
    proc.validate_cert_pol()
    proc.process_csr_chall_pwd()
    proc.create_cert()
    proc.envelope_cert()
    user = Certificate(proc.req_id, proc.info_pwd, proc.e_pwd, proc.cert)
    db.session.add(user)
    db.session.commit()
    send_file(f"{tmpdirname}/tmp_cert.der")
    shutil.rmtree(tmpdirname)
    return base64.b64encode(proc.cert)


@bpki_bp.route('/bpki/enroll2', methods=['GET', 'POST'])
def enroll2():
    pass


@bpki_bp.route('/bpki/enroll3', methods=['GET', 'POST'])
def enroll3():
    pass


@bpki_bp.route('/bpki/reenroll', methods=['GET', 'POST'])
def reenroll():
    pass


@bpki_bp.route('/bpki/spawn', methods=['GET', 'POST'])
def spawn():
    pass


@bpki_bp.route('/bpki/retrieve', methods=['GET', 'POST'])
def retrieve():
    pass


@bpki_bp.route('/bpki/setpwd', methods=['GET', 'POST'])
def setpwd():
    pass


@bpki_bp.route('/bpki/revoke', methods=['GET', 'POST'])
def revoke():
    pass