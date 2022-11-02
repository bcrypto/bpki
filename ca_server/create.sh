#!/bin/bash
echo "== Creating End Entity $1"
cd out
mkdir $1 2> /dev/null
cd ..

openssl genpkey -paramfile out/params256 -out out/$1/privkey_plain

openssl pkcs8 -in out/$1/privkey_plain -topk8 \
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
  -passout pass:$1$1$1 -out out/$1/privkey

source decode.sh out/$1/privkey

openssl req -new -utf8 -nameopt multiline,utf8 -config ./cfg/$1.cfg \
  -reqexts reqexts -key out/$1/privkey -passin pass:$1$1$1 \
  -out out/$1/csr -batch

openssl ca -name ca1 -batch -in out/$1/csr -key ca1ca1ca1 -days $2 \
  -extfile ./cfg/$1.cfg -extensions exts -out out/$1/cert -notext \
  -utf8 2> /dev/null

source decode.sh out/$1/cert
