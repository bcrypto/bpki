#!/bin/bash

echo "== Initializing PKI ======================================================"

mkdir out 2> /dev/null

ldt=$(date +"%Y%m%d%H%M%S%z")

echo GeneralizedTime = $ldt

echo "== 1 Copy Params ========================================================="

cp -f ../ca_server/out/params256 out/params256 2> /dev/null
cp -f ../ca_server/out/params384 out/params384 2> /dev/null
cp -f ../ca_server/out/params512 out/params512 2> /dev/null

echo "== 2 Copy CA0 certificate (Root CA) ======================================"

mkdir out/ca0 2> /dev/null
cp -f ../ca_server/out/ca0/cert out/ca0/cert  2> /dev/null
cp -f ../ca_server/out/ca0/cert.der out/ca0/cert.der  2> /dev/null
cp -f ../ca_server/out/ca0/crl0.der out/ca0/crl0.der  2> /dev/null

echo "== 3 Copy CA1 certificate (Republican CA) ================================"

mkdir out/ca1 2> /dev/null
cp -f ../ca_server/out/ca1/cert out/ca1/cert  2> /dev/null
cp -f ../ca_server/out/ca1/cert.der out/ca1/cert.der  2> /dev/null
cp -f ../ca_server/out/ca1/chain out/ca1/chain  2> /dev/null
cat out/ca0/cert.der out/ca1/cert.der > out/ca1/chain.der

#echo "== 4 Copy CA2 certificate  (Subordinate CA) ============================="

#cp -f ../ca_server/out/ca2/cert out/ca2/cert 2> /dev/null

echo "== 5 Copy End Entities data =============================================="

#bash ./create.sh aa 1825
#bash ./create.sh ra 1825
#bash ./create.sh ocsp 1095
mkdir out/ocsp 2> /dev/null
cp -f ../ca_server/out/ocsp/cert out/ocsp/cert 2> /dev/null
cp -f ../ca_server/out/ocsp/cert.der out/ocsp/cert.der 2> /dev/null
#bash ./create.sh tsa 1825
mkdir out/tsa 2> /dev/null
cp -f ../ca_server/out/tsa/cert out/tsa/cert 2> /dev/null
cp -f ../ca_server/out/tsa/cert.der out/tsa/cert.der 2> /dev/null
#bash ./create.sh dvcs 1825
#bash ./create.sh ids 1095
#bash ./create.sh tls 1095
#bash ./create.sh opra 730
mkdir out/opra 2> /dev/null
cp -f ../ca_server/out/opra/cert out/opra/cert 2> /dev/null
cp -f ../ca_server/out/opra/cert.der out/opra/cert.der 2> /dev/null
cp -f ../ca_server/out/opra/privkey out/opra/privkey 2> /dev/null
cp -f ../ca_server/out/opra/privkey.der out/opra/privkey.der 2> /dev/null
cp -f ../ca_server/out/opra/privkey_plain out/opra/privkey_plain 2> /dev/null
#bash ./create.sh agca1 1095

echo "== 6 Copy CRL before and after revoking opra (for OCSP testing) =========="

cp -f ../ca_server/out/ca1/crl1  out/ca1/crl1  2> /dev/null
cp -f ../ca_server/out/ca1/crl1.der  out/ca1/crl1.der  2> /dev/null
cp -f ../ca_server/out/ca1/crl2  out/ca1/crl2  2> /dev/null
cp -f ../ca_server/out/ca1/crl2.der  out/ca1/crl2.der  2> /dev/null

echo "== 7 Copy revoked opra certificate ======================================="

cp -f ../ca_server/out/opra/cert0 out/opra/cert0 2> /dev/null

echo "== End ==================================================================="
