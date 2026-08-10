FROM btls/btls256

RUN apt-get update
RUN apt-get update \
    && apt-get install -y \
        gcc \
        postgresql-16 \
        libpq-dev \
        libssl-dev \
        python3-dev \
        python3-venv \
        python3-pip \
    && apt-get autoremove --purge \
    && rm -rf /var/lib/apt/lists/*

# Adjust PostgreSQL configuration so that remote connections to the
# database are possible.
RUN echo "host all  all    0.0.0.0/0  md5" >> /etc/postgresql/16/main/pg_hba.conf

# And add ``listen_addresses`` to ``/etc/postgresql/16/main/postgresql.conf``
RUN echo "listen_addresses='*'" >> /etc/postgresql/16/main/postgresql.conf

COPY app/user/up.sql /init.sql

COPY requirements.txt ./
COPY bpkipy/ /bpkipy/
    # Создание виртуального окружения Python

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip setuptools \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt \
    && /opt/venv/bin/pip install /bpkipy

# Expose the PostgreSQL port
EXPOSE 5432

WORKDIR /app
