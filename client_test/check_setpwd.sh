#!/bin/bash

export OPENSSL_CONF=openssl.cfg

echo "--1  Decode Signed(Response($1))"
bash dump.sh answers/$1/setpwd_resp.der
# cat answers/$1/setpwd_resp.der

echo "--2  Verify Signed(Response)"
openssl cms -verify -in answers/$1/setpwd_resp.der -inform der \
  -CAfile out/ca1/chain -out answers/$1/set_pwd_resp.der -outform der -purpose any

echo "--3  Decode Response"
bash dump.sh answers/$1/set_pwd_resp.der
cat answers/$1/set_pwd_resp.der.txt
