from app import db


class User(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    req_id = db.Column(db.String)
    info_pwd = db.Column(db.String)
    e_pwd = db.Column(db.String);
    cert = db.Column(db.LargeBinary)

    def __init__(self, req_id_, info_pwd, e_pwd, cert):
        self.req_id = req_id_
        self.info_pwd = info_pwd
        self.e_pwd = e_pwd
        self.cert = cert

    def __repr__(self):
        return '<User %d>' % self.req_id

    def set_cert(self, cert):
        self.cert = cert
