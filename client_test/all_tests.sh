#!/bin/bash

# 0 Copy relevant certificates
bash cert_copy.sh
bash dumpasn1b.sh

# 1 Healthcheck
python3 healthcheck.py

# 2 TSA
bash test_tsa.sh

# 3 Enroll1
bash test_enroll1.sh lr

# 4 Bad Enroll1
python post_bad_enroll1.py
bash check_bad_enroll.sh

# 5 OCSP
bash test_ocsp.sh
