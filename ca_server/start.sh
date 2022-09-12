service postgresql start
export PATH=$OPENSSL_PATH:$PATH
export  LD_LIBRARY_PATH=$LIBSSL_PATH:$LD_LIBRARY_PATH
gunicorn wsgi:app --bind 0.0.0.0:80 --config /app/app/conf/gunicorn.py