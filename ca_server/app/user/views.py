from flask import request, jsonify, Blueprint
from app import app, db
from app.user.models import Certificate

users = Blueprint('users', __name__)


@users.route('/')
@users.route('/home')
def home():
    return "Welcome to the Users Home."


@users.route('/get_users', methods=['GET'])
def get_users():
    rows = Certificate.query.all()
    res = {}
    for user in rows:
        res[user.id] = {
            'revoke_pwd': user.revoke_pwd,
            'info_pwd': user.info_pwd,
            'serial': user.serial_num,
            'req_id': user.req_id,
            'cert': user.cert
        }
    return jsonify(res)


@users.route('/create_user', methods=['POST', 'GET'])
def create_user():
    user1 = Certificate("1234567", "info", "12345", "cert")
    user1.revoke_pwd = "epwd"
    db.session.add(user1)
    db.session.commit()
    return 'Product created.'
