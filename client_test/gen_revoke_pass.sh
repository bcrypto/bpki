#!/bin/bash

#rem ===========================================================================
# \brief Процесc Revoke (без подписи)
#rem \project bpki/client_test
#rem \created 2022.11.30
#rem \version 2022.11.30
#rem \params $1 -- конечный участник
#rem \params $2 -- пароль отзыва
#rem \pre Имеется сертификат ./answers/$1/cert.der
#rem ===========================================================================

export OPENSSL_CONF=openssl.cfg

echo "-- 1 BPKIRevokeReq($1) creation --"
python create_revoke.py $1 $2

# echo "stored in out/$1/revoke_req.der"
bash dump.sh out/$1/revoke_req.der

echo "-- 3 enveloping BPKIRevokeReq($1) for CA1"

openssl cms -encrypt -binary -in out/$1/revoke_req.der -inform der \
  -recip out/ca1/cert -belt-cfb256 \
  -out out/$1/enveloped_revoke1.der -outform der

echo stored in out/$1/enveloped_revoke1.der

echo "-- 6 calculating reqid = hash(Enveloped(Signed(BPKIRevokeReq($1))))"

openssl dgst -belt-hash out/$1/enveloped_revoke1.der \
  -hex > out/$1/rev_reqid.txt 2> /dev/null

# cat out/$1/rev_reqid.txt
sed -iE "s/.*=\ //" "out/$1/rev_reqid.txt"
cat out/$1/rev_reqid.txt
