service postgresql start
echo "$PGPASSWORD"
gunicorn wsgi:app --bind 0.0.0.0:80 --config /app/app/conf/gunicorn.py