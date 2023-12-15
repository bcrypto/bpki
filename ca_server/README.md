Run CA server
-------------

Preparations
------------

### Building Bee2evp. 
See instructions in [github.com/bcrypto/bee2evp](https://github.com/bcrypto/bee2evp).

### Install gunicorn. 
See instructions in [docs.gunicorn.org](https://docs.gunicorn.org/en/stable/install.html).

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

### Local debug server
```commandline
$ python wsgi.py
```

### Docker
Install docker and docker-compose
- Linux
```commandline
$ sudo apt install docker-compose
```
Build docker image:
```
$ docker-compose build bpki_ca
```
Start server:
```
$ docker-compose up bpki_ca
```

### Database administration on image
Connect to docker image with terminal:
```commandline
docker-compose run bpki_ca bash
```

Start PostgreSQL server:
```commandline
service postgresql start
```

Connect to DB on Docker image:
```commandline
psql -h localhost -p 5432 -U docker
```

Initialize DB in psql:
```commandline
# \i  /root/up.sql
```
or
```commandline
# \i  /app/app/user/up.sql
```

### Database administration from host
Connect to DB on Docker image:
```commandline
psql -h localhost -p 54321 -U docker
```
Initialize DB in psql:
```commandline
# \i  app/user/up.sql
```
Exit from psql:
```commandline
# \q
```

Note: use "-U test" for bpki_test_ca environment

### Test data generation
Connect to docker image with terminal:
```commandline
docker-compose run bpki_test_ca bash
```

Setup CA keys and certificates
```
# bash setup_test.sh
```

Change ownership of CA files:
```commandline
sudo chown -R $USER:$USER test_ca
```
