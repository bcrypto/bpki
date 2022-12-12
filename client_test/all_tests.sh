#!/bin/bash

# 0 Copy relevant certificates
bash cert_copy.sh

# 1 Healthcheck
echo "01 ----- Healthcheck Test -----------------------------"
python3 healthcheck.py

# 2 TSA
echo "02 ----- Test TimeStamps ------------------------------"
bash test_tsa.sh

# 3 Enroll1
echo "03 ----- Test Enroll1 ---------------------------------"
bash test_enroll1.sh lr

# 4 Bad Enroll1
echo "04 ----- BPKIResp test on BAD request for Enroll1 -----"
python3 post_bad_enroll1.py
bash check_bad_enroll.sh

# 5 OCSP
echo "05 ----- OCSP test ------------------------------------"
bash test_ocsp.sh lr

# 6 CRL
echo "06 ----- CRL loading test -----------------------------"
python3 get_crl.py
bash dump.sh answers/crl1.der

# 7 Setpwd
echo "07 ----- SetPwd test ----------------------------------"
bash test_setpwd.sh lr

# 8 Bad DVCS request
echo "08 ----- DVCS test on BAD request ---------------------"
python3 post_bad_dvcs.py
bash check_bad_dvcs.sh

# 8 DVCS request
echo "09 ----- DVCS test on GOOD request --------------------"
python3 post_dvcs.py lr
bash check_dvcs.sh lr

# 9 Reenroll
echo "10 ----- Test reenroll ---------------------------------"
bash test_reenroll.sh lr

# 10 Spawn
echo "11 ----- Test spawn ------------------------------------"
bash test_spawn.sh lr

# 11 Revoke
echo "12 ----- Test revoke -----------------------------------"
bash test_revoke.sh lr

# 12 Revoke without sign
echo "13 ----- Test revoke on PWD ----------------------------"
bash test_revoke_pass.sh lr

# 13 Use revoked cert
echo "14 ----- Test SetPwd for Revoked Cert ------------------"
bash check_crl.sh lr


