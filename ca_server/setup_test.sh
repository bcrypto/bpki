#!/bin/bash
echo "== Initializing PKI ======================================================"

if [[ -z "${OPENSSL_CONF}" ]]; then
  echo "Error: OPENSSL_CONF is undefined"
  exit 1
fi

if [[ -z "${CA_HOME}" ]]; then
  echo "Error: CA_HOME is undefined"
  exit 1
fi

if [[ -z "${CA_CFG}" ]]; then
  echo "Error: CA_CFG is undefined"
  exit 1
fi

SCRIPT_DIR=$(pwd)

rm -rf $CA_HOME 2> /dev/null
mkdir $CA_HOME 2> /dev/null


ldt=$(date +"%Y%m%d%H%M%S%z")

echo GeneralizedTime = $ldt

echo "== 1 Generating Params ==================================================="

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve256v1 -out $CA_HOME/params256

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve384v1 -out $CA_HOME/params384

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve512v1 -out $CA_HOME/params512

openssl pkeyparam -in $CA_HOME/params256 -noout -text
openssl pkeyparam -in $CA_HOME/params256 -noout -check
openssl pkeyparam -in $CA_HOME/params384 -noout -text
openssl pkeyparam -in $CA_HOME/params256 -noout -check
openssl pkeyparam -in $CA_HOME/params512 -noout -text
openssl pkeyparam -in $CA_HOME/params256 -noout -check

echo "== 2 Creating CA0 (Root CA) =============================================="

cd $CA_HOME
mkdir ca0 2> /dev/null
cd ca0
cat /dev/null > index.txt
echo 01 > crlnumber
mkdir certs 2> /dev/null
cd $SCRIPT_DIR

openssl genpkey -paramfile $CA_HOME/params512 \
  -pkeyopt enc_params:specified -pkeyopt enc_params:cofactor \
  -out $CA_HOME/ca0/privkey_plain

# decode $CA_HOME/ca0/privkey_plain > nul

openssl pkcs8 -in $CA_HOME/ca0/privkey_plain -topk8 \
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
  -passout pass:ca0ca0ca0 -out $CA_HOME/ca0/privkey

openssl pkey -in $CA_HOME/ca0/privkey -passin pass:ca0ca0ca0 -noout -check

source decode.sh $CA_HOME/ca0/privkey

openssl req -new -utf8 -nameopt multiline,utf8 -config $CA_CFG/ca0.cfg \
  -key $CA_HOME/ca0/privkey -passin pass:ca0ca0ca0 -out $CA_HOME/ca0/csr -batch

# call decode $CA_HOME/ca0/csr > nul

openssl x509 -req -extfile $CA_CFG/ca0.cfg -extensions exts -days 7300 \
  -in $CA_HOME/ca0/csr -signkey $CA_HOME/ca0/privkey -passin pass:ca0ca0ca0 \
  -out $CA_HOME/ca0/cert 2> /dev/null

source decode.sh $CA_HOME/ca0/cert

openssl ca -gencrl -name ca0 -key ca0ca0ca0 -crldays 1825 -crlhours 6 \
  -crlexts crlexts -out $CA_HOME/ca0/crl0 -batch 2> /dev/null

source decode.sh $CA_HOME/ca0/crl0

echo ok

echo "== 3 Creating CA1 (Republican CA) ========================================"

cd $CA_HOME
mkdir ca1 2> /dev/null
cd ca1
cat /dev/null > index.txt
echo 01 > crlnumber
mkdir certs 2> /dev/null
cd $SCRIPT_DIR

openssl genpkey -paramfile $CA_HOME/params384 \
-pkeyopt enc_params:specified -out $CA_HOME/ca1/privkey_plain

#call decode $CA_HOME/ca1/privkey_plain > nul#

openssl pkcs8 -in $CA_HOME/ca1/privkey_plain -topk8 \
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
  -passout pass:ca1ca1ca1 -out $CA_HOME/ca1/privkey

openssl pkey -in $CA_HOME/ca1/privkey -passin pass:ca1ca1ca1 -noout -pubcheck

source decode.sh $CA_HOME/ca1/privkey

openssl req -new -utf8 -nameopt multiline,utf8 -config $CA_CFG/ca1.cfg \
  -key $CA_HOME/ca1/privkey -passin pass:ca1ca1ca1 -out $CA_HOME/ca1/csr -batch

#call decode $CA_HOME/ca1/csr > nul#

openssl ca -name ca0 -create_serial -batch -in $CA_HOME/ca1/csr -days 3650 \
  -key ca0ca0ca0 -extfile $CA_CFG/ca1.cfg -extensions exts \
  -out $CA_HOME/ca1/cert -notext -utf8 2> /dev/null

source decode.sh $CA_HOME/ca1/cert

echo ok

echo "== 4 Creating CA2 (Subordinate CA) ======================================="

cd $CA_HOME
mkdir ca2 2> /dev/null
cd ca2
cat /dev/null > index.txt
echo 01 > crlnumber
mkdir certs 2> /dev/null
cd $SCRIPT_DIR

openssl genpkey -paramfile $CA_HOME/params256 -pkeyopt enc_params:cofactor \
  -out $CA_HOME/ca2/privkey_plain

#call decode $CA_HOME/ca2/privkey_plain > nul#

openssl pkcs8 -in $CA_HOME/ca2/privkey_plain -topk8 \
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
  -passout pass:ca2ca2ca2 -out $CA_HOME/ca2/privkey

source decode.sh $CA_HOME/ca1/privkey

openssl req -new -utf8 -nameopt multiline,utf8 -config $CA_CFG/ca2.cfg \
  -key $CA_HOME/ca2/privkey -passin pass:ca2ca2ca2 -out $CA_HOME/ca2/csr -batch

#call decode $CA_HOME/ca2/csr > nul#

openssl ca -name ca1 -create_serial -batch -in $CA_HOME/ca2/csr \
  -key ca1ca1ca1 -extfile $CA_CFG/ca2.cfg -extensions exts \
  -out $CA_HOME/ca2/cert -notext -utf8 2> /dev/null

source decode.sh $CA_HOME/ca2/cert

echo ok

echo "== 5 Creating End Entities ==============================================="

source create.sh aa 1825
source create.sh ra 1825
source create.sh ocsp 1825
source create.sh tsa 1825
source create.sh dvcs 1825
source create.sh ids 1825
source create.sh tls 1825
source create.sh opra 1825
source create.sh agca1 1825

echo 00 > $CA_HOME/tsa/tsaserial
cat $CA_HOME/ca0/cert $CA_HOME/ca1/cert > $CA_HOME/ca1/chain
cat $CA_HOME/ca0/cert.der $CA_HOME/ca1/cert.der > $CA_HOME/ca1/chain.der

echo "== 6 Revoking opra (for OCSP testing) ===================================="

cp -f $CA_HOME/opra/cert $CA_HOME/opra/cert0 > /dev/null

openssl ca -gencrl -name ca1 -key ca1ca1ca1 -crldays 1825 -crlhours 6 \
  -crlexts crlexts -out $CA_HOME/ca1/crl1 -batch 2> /dev/null

source decode.sh $CA_HOME/ca1/crl1

openssl ca -revoke $CA_HOME/opra/cert0 -name ca1 -key ca1ca1ca1 \
  -crl_reason keyCompromise -crl_compromise $ldt -batch

openssl ca -gencrl -name ca1 -key ca1ca1ca1 -crldays 1825 -crlhours 1 \
  -crlexts crlexts -out $CA_HOME/ca1/crl2 -batch 2> /dev/null

source decode.sh $CA_HOME/ca1/crl2

echo "== 7 Creating opra again ================================================="

source create.sh opra 1825

#:End#

echo "== End ==================================================================="
