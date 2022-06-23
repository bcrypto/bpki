from flask import Blueprint

tls_bp = Blueprint('tls_bp', __name__,
                   template_folder='../templates',
                   static_folder='../static')