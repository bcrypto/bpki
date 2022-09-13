# 0 Copy relevant certificates
bash cert_copy.sh

# 1 Healthcheck
python3 healthcheck.py

# 2 TSA
bash tsa.sh
python3 post_tsa.py
bash check_tsa.sh

# 3 Enroll1
bash test_enroll1.sh lr

