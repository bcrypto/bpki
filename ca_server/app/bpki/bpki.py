import base64
import os

from flask import Blueprint, render_template, request, current_app
from flask import send_file

from app import db
from app.user.models import Certificate
from .tsa import tsa_req
from .ocsp import ocsp_req
from .enroll import Enroll1
from .revoke import Revoke
from .openssl import openssl
import bpkipy

out_path = os.getcwd() + '/out/'

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
    _, version, _ = openssl(cmd)
    cmd = "version -d"
    _, _, _ = openssl(cmd)
    cmd = "engine -c -t bee2evp"
    ret_3, _, _ = openssl(cmd)
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


@bpki_bp.route('/bpki/ocsp', methods=['POST'])
def ocsp():
    data = request.get_data()
    req = base64.b64decode(data)
    answer = ocsp_req(req)
    return base64.b64encode(answer)


@bpki_bp.route('/bpki/crl', methods=['GET'])
def crl():
    cmd = (f"ca -gencrl -name ca1 -key ca1ca1ca1 -crldays 1 -crlhours 6 "
            f" -crlexts crlexts -out {out_path}current_crl -batch")
    openssl(cmd)
    cmd = f"crl -in {out_path}current_crl -outform DER -out {out_path}current_crl.der"
    openssl(cmd)
    try:
        return send_file(f'{out_path}/current_crl.der', download_name='crl')
    except Exception as e:
        return str(e)


@bpki_bp.route('/bpki/enroll1', methods=['POST'])
def enroll1():
    data = request.get_data()
    req = base64.b64decode(data)
    # result = None
    try:
        proc = Enroll1(message=req, tmp_name="enveloped_signed_csr")
        proc.decrypt("enveloped_signed_csr", "recovered_signed_csr")
        proc.verify("recovered_signed_csr", "verified_csr.der")
        proc.extract_csr()
        # proc.validate_cert_pol()
        proc.process_csr_chall_pwd()
        proc.create_cert()
        proc.envelope_cert(recip_cert=f"{out_path}opra/cert")
        reg_data = proc.reg_data()

        current_app.logger.debug('Add item to table: %s', str(reg_data))
        user = Certificate(*reg_data)
        db.session.add(user)
        db.session.commit()
        result = proc.enveloped_cert
    except Exception as e:
        current_app.logger.error('Enroll1: ' + str(e))
        error_list = [str(e)]
        resp = bpkipy.create_response(
            status=2, req_id=bytes.fromhex(proc.req_id), error_list=error_list
        )
        result = proc.sign_response(resp)

    return base64.b64encode(result)


@bpki_bp.route('/bpki/enroll2', methods=['GET', 'POST'])
def enroll2():
    pass


@bpki_bp.route('/bpki/enroll3', methods=['POST'])
def enroll3():
    data = request.get_data()
    req = base64.b64decode(data)
    # result = None
    try:
        proc = Enroll1(message=req, tmp_name="enveloped_csr")
        proc.decrypt("enveloped_csr", "verified_csr.der")
        proc.extract_csr()
        # proc.validate_cert_pol()
        # TODO: extract and check EPWD like process_csr_chall_pwd()
        proc.create_cert()
        proc.envelope_cert()
        reg_data = proc.reg_data()

        current_app.logger.debug('Add item to table: %s', str(reg_data))
        user = Certificate(*reg_data)
        db.session.add(user)
        db.session.commit()
        result = proc.enveloped_cert
    except Exception as e:
        current_app.logger.error('Enroll3: ' + str(e))
        error_list = [str(e)]
        resp = bpkipy.create_response(
            status=2, req_id=bytes.fromhex(proc.req_id), error_list=error_list
        )
        result = proc.sign_response(resp)

    return base64.b64encode(result)


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
    data = request.get_data()
    req = base64.b64decode(data)
    try:
        proc = Revoke(message=req, tmp_name="enveloped_signed_csr")
        proc.decrypt("enveloped_signed_csr", "recovered_signed_csr")
        proc.verify("recovered_signed_csr", "verified_csr.der")
        proc.parse("verified_csr.der")
        # TODO: check issuer

        account = db.session.query(Certificate).filter_by(serial_num=bytes.fromhex(proc.rev_data['serial'][2:])).first()
        current_app.logger.error('Status: ' + account.status)
        if account.status == 'Actual':
            account.status = 'Revoked'
            db.session.commit()
            # TODO: revoke certificate with OpenSSL command
            current_app.logger.error('Revoke completed.')
            result = bpkipy.create_response(
                status=0, req_id=bytes.fromhex(proc.req_id), error_list=["Revoked successfully."]
            )
        else:
            result = bpkipy.create_response(
                status=2, req_id=bytes.fromhex(proc.req_id), error_list=["Certificate had been revoked."]
            )
    except Exception as e:
        current_app.logger.error('Revoke: ' + str(e))
        error_list = [str(e)]
        result = bpkipy.create_response(
            status=2, req_id=bytes.fromhex(proc.req_id), error_list=error_list
        )

    return base64.b64encode(proc.sign_response(result))
