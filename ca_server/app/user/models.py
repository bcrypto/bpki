from app import db


class Certificate(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    revoke_pwd = db.Column(db.String)
    info_pwd = db.Column(db.String)
    serial_num = db.Column(db.LargeBinary)
    req_id = db.Column(db.LargeBinary)
    cert = db.Column(db.LargeBinary)

    def __init__(self, serial, info_pwd, req_id, cert):
        self.revoke_pwd = None
        self.info_pwd = info_pwd
        self.serial_num = serial
        self.req_id = req_id
        self.cert = cert

    def __repr__(self):
        return '<User %s>' % self.serial_num

    def set_cert(self, cert):
        self.cert = cert

    def set_revoke_pwd(self, revoke_pwd):
        self.revoke_pwd = revoke_pwd
