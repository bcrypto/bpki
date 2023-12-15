FROM btls/bee2evp

COPY requirements.txt ./

ENV TZ=Europe/Minsk
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get update \ 
    && apt-get upgrade -y -q\
    && apt-get install -y -q \
        gcc \
        postgresql-14 \
        libpq-dev \
        libssl-dev \
        python3-dev \
        python3-pip \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir -r requirements.txt

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/14/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/14/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/14/main/postgresql.conf

#RUN service postgresql start

# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
#USER postgres
COPY app/user/up.sql ./up.sql

# TODO: create user postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN service postgresql start &&\
    runuser -u postgres -- psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    runuser -u postgres -- createdb -O docker docker &&\
    runuser -u postgres -- psql --command "CREATE USER test WITH SUPERUSER PASSWORD 'test';" &&\
    runuser -u postgres -- createdb -O test test

# RUN service postgresql restart &&\
#    psql "dbname='docker' user='docker' password='docker'" -f up.sql

COPY bpkipy/ ./bpkipy/
RUN python3 -m pip install ./bpkipy

# Add VOLUMEs to allow backup of config, logs and databases
# RUN mkdir /etc/postgresql && mkdir /var/log/postgresql && mkdir /var/lib/postgresql
VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

# Expose the PostgreSQL port
EXPOSE 5432

#CMD    /etc/init.d/postgresql start

#COPY ./app /app

WORKDIR /app