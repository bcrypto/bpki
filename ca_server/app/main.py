"""Application entry point."""
# from ensurepip import bootstrap
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

from flask_bootstrap import Bootstrap
from conf.config import Config

app = Flask(__name__, instance_relative_config=False)
Bootstrap(app)
app.config.from_object('conf.config.Config')
db = SQLAlchemy(app)

with app.app_context():
    from bpki import bpki
    from user.views import users

    app.register_blueprint(bpki.bpki_bp)

    app.register_blueprint(users)
    bpki.update_crl()
    db.create_all()

if __name__ == "__main__":
    app.run(host="0.0.0.0", port="80")