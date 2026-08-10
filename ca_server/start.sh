#!/bin/bash
set -e

# Переменные по умолчанию (можно переопределять при docker run -e)
DB_USER="${POSTGRES_USER:-docker}"
DB_PASSWORD="${POSTGRES_PASSWORD:-docker}"
DB_NAME="${POSTGRES_DB:-docker}"
export PATH=$OPENSSL_PATH:$PATH
export  LD_LIBRARY_PATH=$LIBSSL_PATH:$LD_LIBRARY_PATH

# Временный запуск службы PostgreSQL
service postgresql start

# Проверка, создан ли уже пользователь
USER_EXISTS=$(su - postgres -c "psql -tAc \"SELECT 1 FROM pg_roles WHERE rolname='$DB_USER'\"")

if [ "$USER_EXISTS" != "1" ]; then

    # Инициализация УЦ
    if [ -f /app/setup.sh ]; then
        echo "Инициализация УЦ..."
        export OPENSSL_CONF=app_openssl.cfg
        source /app/setup.sh
    fi

    echo "Инициализация базы данных и пользователя..." 
    # Создание пользователя и базы данных
    su - postgres -c "psql -c \"CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';\""
    su - postgres -c "psql -c \"CREATE DATABASE $DB_NAME OWNER $DB_USER;\""
    su - postgres -c "psql -c \"GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;\""

    # Выполнение готового SQL-скрипта
    if [ -f /init.sql ]; then
        echo "Выполнение init.sql..."
        su - postgres -c "psql -d $DB_NAME -f /init.sql"
    fi
fi

source /opt/venv/bin/activate

gunicorn wsgi:app --bind 0.0.0.0:80 --config /app/app/conf/gunicorn.py