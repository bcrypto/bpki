Run CA server
-------------

### Terminal 1
```
$ ngrok http 5000
```
Copy https url from ngrok and paste it in `./app/bpki/static/js/index.js` (variable `api_url`).

### Terminal 2

Make sure postgresql is running.
```
$ gunicorn -w 4 --bind 0.0.0.0:5000 wsgi:app
```

Open in browser url from ngrok.

Preparations
------------

### Building Bee2evp. 
See instructions in [github.com/bcrypto/bee2evp](https://github.com/bcrupto/bee2evp).

### Install gunicorn. 
See instructions in [github.com/agievich/bee2](https://github.com/bcrupto/bee2evp).

### Install ngrok. 
See instructions in [github.com/agievich/bee2](https://github.com/bcrupto/bee2evp).

### Python $\ge$ 3.6
```
$ pip3 install -r requirements.txt
```

### PostgreSQL.

For installation see instructions in [postgreSQL](https://www.postgresql.org/download/).

Create database and change variable `SQLALCHEMY_DATABASE_URI` in `./config.py` in the following format `postgresql://[user[:password]@][netloc][:port][/dbname]`.

Also check lib `libpq-dev`. If not exists run
```
$ sudo apt-get istall libpq-dev
```

Run `./app/user/up.sql` script for creating table.

### Setup certificates
```
$ bash setup.sh
```
