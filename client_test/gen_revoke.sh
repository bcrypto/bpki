#!/bin/bash

#rem ===========================================================================
# \brief Процесc Revoke
#rem \project bpki/client_test
#rem \created 2022.11.30
#rem \version 2022.11.30
#rem \params $1 -- конечный участник
#rem \pre Имеется сертификат ./answers/$1/cert.der
#rem ===========================================================================

export OPENSSL_CONF=openssl.cfg

echo "-- 1 BPKIRevokeReq($1) creation --"
python3 create_revoke.py $1

# echo "stored in out/$1/revoke_req.der"

echo "-- 2 Sign(BPKIRevokeReq($1)) by own cert --"

openssl cms -sign -signer answers/$1/cert \
  -inkey out/$1/privkey -passin pass:$1$1$1 \
  -in out/$1/revoke_req.der -binary -econtent_type bpki-ct-revoke-req \
  -out out/$1/signed_revoke.der -outform der -nodetach -nosmimecap

echo stored in out/$1/signed_revoke.der

echo "-- 3 enveloping Signed(BPKIRevokeReq($1)) for CA1"

openssl cms -encrypt -binary -in out/$1/signed_revoke.der -inform der \
  -recip out/ca1/cert -belt-cfb256 \
  -out out/$1/enveloped_revoke1.der -outform der

echo stored in out/$1/enveloped_revoke1.der

echo "-- 6 calculating reqid = hash(Enveloped(Signed(BPKIRevokeReq($1))))"

openssl dgst -belt-hash out/$1/enveloped_revoke1.der \
  -hex > out/$1/rev_reqid.txt 2> /dev/null

# cat out/$1/rev_reqid.txt
sed -iE "s/.*=\ //" "out/$1/rev_reqid.txt"
cat out/$1/rev_reqid.txt