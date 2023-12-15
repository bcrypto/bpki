#!/bin/bash
echo "== Creating End Entity $1"

ENTITY_DIR="${CA_HOME:-out}/$1"

CONFIG="${CA_CFG:-cfg}/$1.cfg"

mkdir $ENTITY_DIR 2> /dev/null

openssl genpkey -paramfile $CA_HOME/params256 -out $ENTITY_DIR/privkey_plain

openssl pkcs8 -in $ENTITY_DIR/privkey_plain -topk8 \
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
  -passout pass:$1$1$1 -out $ENTITY_DIR/privkey

source decode.sh $ENTITY_DIR/privkey

openssl req -new -utf8 -nameopt multiline,utf8 -config $CONFIG \
  -reqexts reqexts -key $ENTITY_DIR/privkey -passin pass:$1$1$1 \
  -out $ENTITY_DIR/csr -batch

openssl ca -name ca1 -batch -in $ENTITY_DIR/csr -key ca1ca1ca1 -days $2 \
  -extfile $CONFIG -extensions exts -out $ENTITY_DIR/cert -notext \
  -utf8 2> /dev/null

source decode.sh $ENTITY_DIR/cert
