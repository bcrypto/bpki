#!/bin/bash

# 0 Copy relevant certificates
bash cert_copy.sh

# 1 Healthcheck
python3 healthcheck.py

# 2 TSA
bash test_tsa.sh

# 3 Enroll1
echo "--- Test Enroll1 ---"
bash test_enroll1.sh lr

# 4 Bad Enroll1
echo "--- BPKIResp test on BAD request for Enroll1"
python3 post_bad_enroll1.py
bash check_bad_enroll.sh

# 5 OCSP
bash test_ocsp.sh lr

# 6 CRL
python3 get_crl.py
bash dump.sh answers/crl1.der

# 7 Setpwd
bash test_setpwd.sh lr

# 8 Bad DVCS request
echo "--- DVCS test on BAD request"
python3 post_bad_dvcs.py
bash check_bad_dvcs.sh

# 8 DVCS request
echo "--- DVCS test on GOOD request"
python3 post_dvcs.py lr
bash check_dvcs.sh lr

# 9 Reenroll
echo "--- Test reenroll ---"
bash test_reenroll.sh lr

# 10 Spawn
echo "--- Test spawn ---"
bash test_spawn.sh lr

# 11 Revoke
echo "--- Test revoke ---"
bash test_revoke.sh lr

# 12 Revoke without sign
echo "--- Test revoke on PWD ---"
bash test_revoke_pass.sh lr


