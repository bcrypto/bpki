import os

basedir = os.path.abspath(os.path.dirname(__file__))


class Config(object):
    SECRET_KEY = os.environ.get('SECRET_KEY') or 'you-will-never-guess'
    SQLALCHEMY_DATABASE_URI = 'postgresql://docker:docker@localhost/docker'
    SQLALCHEMY_TRACK_MODIFICATIONS = False
    DEBUG = True
    SERVER_CERT = "/etc/nginx/ssl/cert256.pem"
    SERVER_KEY = "/etc/nginx/ssl/priv256.key"
