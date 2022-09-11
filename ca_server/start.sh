service postgresql start
gunicorn wsgi:app --bind 0.0.0.0:80 --config /app/app/conf/gunicorn.py