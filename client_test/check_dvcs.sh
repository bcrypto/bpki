#!/bin/bash

export OPENSSL_CONF=openssl.cfg

echo "--1  Decode Signed(Response)"
bash dump.sh answers/$1/dvcs_resp.der
# cat answers/$1/dvcs_resp.der.txt

echo "--2  Verify Signed(Response)"
openssl cms -verify -in answers/$1/dvcs_resp.der -inform der \
  -CAfile out/ca1/chain -out answers/$1/dvcs_info.der -outform der -purpose any

echo "--3  Decode Response"
bash dump.sh answers/$1/dvcs_info.der
cat answers/$1/dvcs_info.der.txt