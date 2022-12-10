export OPENSSL_CONF=openssl.cfg


echo "-- 1 Update CRL for CA1 --"
python3 get_crl.py
echo stored in answers/crl1.der

echo "-- 2  Convert CRL to PEM"
openssl crl -inform DER -in answers/crl1.der -outform PEM -out answers/crl1
echo stored in answers/crl1

echo "-- 3  Convert Cert($1) to PEM"
openssl x509 -inform DER -in answers/$1/cert.der -outform PEM -out answers/$1/cert
echo stored in answers/$1/cert

echo "-- 4  Verify Cert($1)"
openssl verify -CRLfile answers/crl1 -crl_check -CAfile out/ca1/chain answers/$1/cert

echo "-- 5 Send SetPwd(Cert($1)) --"
bash test_setpwd.sh lr
