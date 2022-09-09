#!/bin/bash
echo "== Initializing PKI ======================================================"

export OPENSSL_CONF=openssl.cfg
mkdir out 2> /dev/null

ldt=$(date +"%Y%m%d%H%M%S%z")

echo GeneralizedTime = $ldt

echo "== 1 Generating Params ==================================================="

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve256v1 -out out/params256

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve384v1 -out out/params384

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve512v1 -out out/params512

openssl pkeyparam -in out/params256 -noout -text
openssl pkeyparam -in out/params256 -noout -check
openssl pkeyparam -in out/params384 -noout -text
openssl pkeyparam -in out/params256 -noout -check
openssl pkeyparam -in out/params512 -noout -text
openssl pkeyparam -in out/params256 -noout -check

echo "== 2 Creating CA0 (Root CA) =============================================="

cd out
mkdir ca0 2> /dev/null
cd ca0
cat /dev/null > index.txt
echo 01 > crlnumber
mkdir certs 2> /dev/null
cd ..
cd ..

openssl genpkey -paramfile out/params512 \
  -pkeyopt enc_params:specified -pkeyopt enc_params:cofactor \
  -out out/ca0/privkey_plain

# decode out/ca0/privkey_plain > nul

openssl pkcs8 -in out/ca0/privkey_plain -topk8 \
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
  -passout pass:ca0ca0ca0 -out out/ca0/privkey

openssl pkey -in out/ca0/privkey -passin pass:ca0ca0ca0 -noout -check

# call decode out/ca0/privkey > nul

openssl req -new -utf8 -nameopt multiline,utf8 -config ./cfg/ca0.cfg \
  -key out/ca0/privkey -passin pass:ca0ca0ca0 -out out/ca0/csr -batch

# call decode out/ca0/csr > nul

openssl x509 -req -extfile ./cfg/ca0.cfg -extensions exts \
  -in out/ca0/csr -signkey out/ca0/privkey -passin pass:ca0ca0ca0 \
  -out out/ca0/cert 2> /dev/null

# call decode out/ca0/cert > nul

echo ok

echo "== 3 Creating CA1 (Republican CA) ========================================"

cd out
mkdir ca1 2> /dev/null
cd ca1
cat /dev/null > index.txt
echo 01 > crlnumber
mkdir certs 2> /dev/null
cd ..
cd ..

openssl genpkey -paramfile out/params384 \
-pkeyopt enc_params:specified -out out/ca1/privkey_plain

#call decode out/ca1/privkey_plain > nul#

openssl pkcs8 -in out/ca1/privkey_plain -topk8 \
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
  -passout pass:ca1ca1ca1 -out out/ca1/privkey

openssl pkey -in out/ca1/privkey -passin pass:ca1ca1ca1 -noout -pubcheck

#call decode out/ca1/privkey > nul#

openssl req -new -utf8 -nameopt multiline,utf8 -config ./cfg/ca1.cfg \
  -key out/ca1/privkey -passin pass:ca1ca1ca1 -out out/ca1/csr -batch

#call decode out/ca1/csr > nul#

openssl ca -name ca0 -create_serial -batch -in out/ca1/csr \
  -key ca0ca0ca0 -extfile ./cfg/ca1.cfg -extensions exts \
  -out out/ca1/cert -notext -utf8 2> /dev/null

#call decode out/ca1/cert > nul#

echo ok

echo "== 4 Creating CA2 (Subordinate CA) ======================================="

cd out
mkdir ca2 2> /dev/null
cd ca2
cat /dev/null > index.txt
echo 01 > crlnumber
mkdir certs 2> /dev/null
cd ..
cd ..

openssl genpkey -paramfile out/params256 -pkeyopt enc_params:cofactor \
  -out out/ca2/privkey_plain

#call decode out/ca2/privkey_plain > nul#

openssl pkcs8 -in out/ca2/privkey_plain -topk8 \
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
  -passout pass:ca2ca2ca2 -out out/ca2/privkey

#call decode out/ca1/privkey > nul#

openssl req -new -utf8 -nameopt multiline,utf8 -config ./cfg/ca2.cfg \
  -key out/ca2/privkey -passin pass:ca2ca2ca2 -out out/ca2/csr -batch

#call decode out/ca2/csr > nul#

openssl ca -name ca1 -create_serial -batch -in out/ca2/csr \
  -key ca1ca1ca1 -extfile ./cfg/ca2.cfg -extensions exts \
  -out out/ca2/cert -notext -utf8 2> /dev/null

#call decode out/ca2/cert > nul#

echo ok

echo "== 5 Creating End Entities ==============================================="

bash ./create.sh aa 1825
bash ./create.sh ra 1825
bash ./create.sh ocsp 1095
bash ./create.sh tsa 1825
bash ./create.sh dvcs 1825
bash ./create.sh ids 1095
bash ./create.sh tls 1095
bash ./create.sh opra 730
bash ./create.sh agca1 1095

echo "== 6 Revoking opra (for OCSP testing) ===================================="

cp -f out/opra/cert out/opra/cert0 > /dev/null

openssl ca -gencrl -name ca1 -key ca1ca1ca1 -crldays 1 -crlhours 6 \
  -crlexts crlexts -out out/ca1/crl1 -batch 2> /dev/null

#call decode out/ca1/crl1 > nul#

openssl ca -revoke out/opra/cert0 -name ca1 -key ca1ca1ca1 \
  -crl_reason keyCompromise -crl_compromise $ldt -batch

openssl ca -gencrl -name ca1 -key ca1ca1ca1 -crlhours 1 \
  -crlexts crlexts -out out/ca1/crl2 -batch 2> /dev/null

#call decode out/ca1/crl2 > nul#

echo "== 7 Creating opra again ================================================="

bash ./create.sh opra 730

#:End#

echo "== End ==================================================================="
