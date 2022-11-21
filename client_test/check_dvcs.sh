#!/bin/bash

export OPENSSL_CONF=openssl.cfg

echo "--1  Decode Signed(Response)"
bash dump.sh answers/dvcs_resp.der
# cat answers/dvcs_resp.der.txt

echo "--2  Verify Signed(Response)"
openssl cms -verify -in answers/dvcs_resp.der -inform der \
  -CAfile out/ca1/chain -out answers/dvcs_info.der -outform der -purpose any

echo "--3  Decode Response"
bash dump.sh answers/dvcs_info.der
cat answers/dvcs_info.der.txt