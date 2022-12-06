#!/bin/bash

export OPENSSL_CONF=openssl.cfg

echo "--1 Create Cert($1)"
bash gen_enroll1.sh $1
python3 post_enroll1.py $1
bash check_enroll1.sh $1

echo "--2 Set revoke password for Cert($1)"
bash gen_setpwd.sh $1 1234567
python3 post_setpwd.py $1
bash check_setpwd.sh $1

echo "--3 Revoke Cert($1) by password"
bash gen_revoke_pass.sh $1 1234567
python3 post_revoke.py $1 1
bash check_revoke.sh $1 1
