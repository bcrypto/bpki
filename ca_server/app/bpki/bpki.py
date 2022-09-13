import base64
import os

from flask import Blueprint, render_template, request, send_file, current_app

from app import db
from app.user.models import Certificate
from .tsa import tsa_req
from .enroll import Enroll1
from .openssl import openssl


bpki_path = os.getcwd() + '/app/bpki/'
out_path = bpki_path + 'out/'
enroll1_path = out_path + 'enroll1/'

bpki_bp = Blueprint('bpki_bp', __name__,
                    template_folder='../templates',
                    static_folder='../static')

counter = 0


@bpki_bp.before_request
def log_request_info():
    current_app.logger.debug('Headers: %s', request.headers)   # app.logger ?
    current_app.logger.debug('Body: %s', request.get_data())


@bpki_bp.route('/bpki', methods=['GET'])
def bpki():
    return render_template('bpki.html')


@bpki_bp.route('/bpki/healthcheck', methods=['GET'])
def healthcheck():
    current_app.logger.debug(os.environ)
    cmd = "version"
    ret_1, version, err_ = openssl(cmd)
    current_app.logger.debug(err_)
    current_app.logger.debug(version)
    cmd = "version -d"
    ret_2, id_, err_ = openssl(cmd)
    current_app.logger.debug(err_)
    current_app.logger.debug(id_)
    cmd = "engine -c -t bee2evp"
    ret_3, id_, err_ = openssl(cmd)
    current_app.logger.debug(err_)
    current_app.logger.debug(id_)
    return {"OpenSSL version": str(version),
            "bee2evp support": bool(ret_3)}


@bpki_bp.route('/bpki/tsa', methods=['POST'])
def tsa():
    data = request.get_data()
    req = base64.b64decode(data)
    answer = tsa_req(req)
    return base64.b64encode(answer)


@bpki_bp.route('/bpki/tsa2', methods=['POST'])
def tsa2():
    data = request.get_data()
    req = base64.b64decode(data)
    answer = tsa_req(req, no_nonce=False)
    return base64.b64encode(answer)


@bpki_bp.route('/bpki/ocsp', methods=['GET'])
def ocsp():
    pass


@bpki_bp.route('/bpki/enroll1', methods=['POST'])
def enroll1():
    current_app.logger.info(request.get_data())
    data = request.get_data()
    req = base64.b64decode(data)

    proc = Enroll1(file=req)
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
