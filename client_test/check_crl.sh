export OPENSSL_CONF=openssl.cfg

echo "-- 1 Sign(Cert($1)) by own cert --"

openssl cms -sign -signer answers/$1/cert \
  -inkey out/$1/privkey -passin pass:$1$1$1 \
  -in answers/$1/cert.der -binary -econtent_type bpki-ct-revoke-req \
  -out out/$1/signed_cert.der -outform der -nodetach -nosmimecap

echo stored in out/$1/signed_revoke.der

echo "-- 2  Convert CRL to PEM"
openssl crl -inform DER -in answers/crl1.der -outform PEM -out answers/crl1
echo stored in answers/crl1

echo "-- 3  Convert Cert($1) to PEM"
openssl x509 -inform DER -in answers/$1/cert.der -outform PEM -out answers/$1/cert
echo stored in answers/$1/cert


echo "-- 4  Verify Cert($1)"
openssl verify -CRLfile answers/crl1 -crl_check_all -CAfile out/ca1/chain answers/$1/cert


echo "-- 5  Verify Signed(Cert($1))"
openssl cms -verify -in out/$1/signed_cert.der -inform der \
  -CAfile out/ca1/chain -out answers/bpkiresp.der -outform der -purpose any
