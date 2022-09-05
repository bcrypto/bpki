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
            'req_id': user.req_id,
            'info_pwd': user.info_pwd,
            'e_pwd': user.e_pwd,
            'cert': user.cert
        }
    return jsonify(res)

@users.route('/create_user', methods=['POST', 'GET'])
def create_user():
    user1 = Certificate("1234567")
    user1.info_pwd = "info"
    user1.e_pwd = "epwd"
    user1.cert = "cert"
    db.session.add(user1)
    db.session.commit()
    return 'Product created.'
