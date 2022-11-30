#!/bin/bash

echo "-- 1 dump Signed(Revoke($1))"

echo "--1  Decode Signed(Response)"
bash dump.sh answers/$1/rev_resp$2.der
# cat answers/bpki_resp.der.txt

echo "--2  Verify Signed(Response)"
openssl cms -verify -in answers/$1/rev_resp$2.der -inform der \
  -CAfile out/ca1/chain -out answers/$1/revoke_resp$2.der -outform der -purpose any

echo "--3  Decode Response"
bash dump.sh answers/$1/revoke_resp$2.der
cat answers/$1/revoke_resp$2.der.txt
