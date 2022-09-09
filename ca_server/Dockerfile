FROM btls/btls256

COPY requirements.txt ./
RUN apt-get update
RUN apt-get update \
    && apt-get install -y \
        gcc \
        postgresql \
        libpq-dev \
        python3-dev \
        python3-pip \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache-dir -r requirements.txt


# Run the rest of the commands as the ``postgres`` user created by the ``postgres-9.3`` package when it was ``apt-get installed``
USER postgres

# Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
# then create a database `docker` owned by the ``docker`` role.
# Note: here we use ``&&\`` to run commands one after the other - the ``\``
#       allows the RUN command to span multiple lines.
RUN    /etc/init.d/postgresql start &&\
    psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
    createdb -O docker docker

USER root

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/12/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/9.3/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/12/main/postgresql.conf

# Expose the PostgreSQL port
EXPOSE 5432

# Add VOLUMEs to allow backup of config, logs and databases
#VOLUME  ["/etc/postgresql", "/var/log/postgresql", "/var/lib/postgresql"]

#CMD    /etc/init.d/postgresql start

#COPY ./app /app

WORKDIR /app