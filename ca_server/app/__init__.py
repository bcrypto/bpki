from ensurepip import bootstrap
from flask import Flask
from flask_sqlalchemy import SQLAlchemy

from flask_bootstrap import Bootstrap
from config import Config

app = Flask(__name__, instance_relative_config=False)
Bootstrap(app)
app.config.from_object('config.Config')
db = SQLAlchemy(app)

with app.app_context():
    from .bpki import bpki
    from app.user.views import users

    app.register_blueprint(bpki.bpki_bp)

    app.register_blueprint(users)
    db.create_all()


