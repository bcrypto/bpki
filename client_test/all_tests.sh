#!/bin/bash

# 0 Copy relevant certificates
bash cert_copy.sh

# 1 Healthcheck
python3 healthcheck.py

# 2 TSA
bash test_tsa.sh

# 3 Enroll1
bash test_enroll1.sh lr

# 4 Bad Enroll1
echo "--- BPKIResp test on BAD request for Enroll1"
python post_bad_enroll1.py
bash check_bad_enroll.sh

# 5 OCSP
bash test_ocsp.sh lr

# 6 CRL
python get_crl.py
bash dump.sh answers/crl1.der

# 7 Setpwd
bash test_setpwd.sh lr

# 8 Bad DVCS request
echo "--- DVCS test on BAD request"
python post_bad_dvcs.py
bash check_bad_dvcs.sh

# 8 DVCS request
echo "--- DVCS test on GOOD request"
python post_dvcs.py lr
bash check_dvcs.sh lr

# 9 Reenroll
bash test_reenroll.sh lr

# 10 Spawn
bash test_spawn.sh lr

# 11 Revoke
bash test_revoke.sh lr

