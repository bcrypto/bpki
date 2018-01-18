@echo off
rem ===========================================================================
rem \brief Процесc Enroll2
rem \project bpki/demo
rem \params %1 -- конечный участник, %2 -- срок действия (дней)
rem \pre Имеется конфигурационный файл ./cfg/%1.cfg 
rem \post Сертификат out/%1/cert_%1 и промежуточные объекты.
rem ===========================================================================

set OPENSSL_CONF=openssl.cfg

echo    1 preparing dirs 

cd out
md %1 2> NUL
cd ..

echo    2 creating CSR(%1) 

openssl req -new -utf8 -nameopt multiline,utf8 -newkey bign:out/params256 ^
  -config ./cfg/%1.cfg -keyout out/%1/privkey_%1 -reqexts reqexts ^
  -out out/%1/req_%1 -passout pass:%1%1%1 -batch 2> NUL

call decode out/%1/req_%1 > NUL

echo             stored in out/%1/req_%1.der

echo    3 signing CSR(%1) by RA 

openssl cms -sign -signer out/ra/cert_ra ^
  -inkey out/ra/privkey_ra -passin pass:rarara ^
  -in out/%1/req_%1.der -binary -econtent_type pkcs7-data ^
  -out out/%1/signed_req_%1 -outform pem -nodetach -noattr

call decode out/%1/signed_req_%1 > NUL

echo             stored in out/%1/signed_req_%1.der

echo    4 enveloping Signed(CSR(%1)) for CA1 

openssl cms -encrypt -in out/%1/signed_req_%1.der -inform der -binary ^
  -belt-cfb256 -out out/%1/enveloped_signed_req_%1 ^ -outform pem ^
  -recip out/ca1/cert_ca1

call decode out/%1/enveloped_signed_req_%1 > NUL

echo             stored in out/%1/enveloped_signed_req_%1.der

echo    5 calculating a ticket = hash(Enveloped(Signed(CSR(%1)))) 

openssl dgst -belt-hash -binary -out out/%1/req_ticket_%1.bin ^
out/%1/enveloped_signed_req_%1.der 2> NUL

echo             stored in out/%1/req_ticket_%1.bin

echo    6 recovering Enveloped(Signed(CSR(%1))) 

openssl cms -decrypt -in out/%1/enveloped_signed_req_%1 -inform pem ^
  -inkey out/ca1/privkey_ca1 -out out/%1/recovered_signed_req_%1.der ^
  -binary -passin pass:ca1ca1

openssl pkcs7 -in out/%1/recovered_signed_req_%1.der -inform der ^
  -out out/%1/recovered_signed_req_%1 -outform pem > NUL

call decode out/%1/recovered_signed_req_%1 > NUL

echo             stored in out/%1/recovered_signed_req_%1.der

echo    7 verifying Signed(CSR(%1)) 

copy out\ca0\cert_ca0 + out\ca1\cert_ca1 out\%1\chain_ra > NUL

openssl cms -verify -in out/%1/recovered_signed_req_%1 -inform pem ^
  -CAfile out/%1/chain_ra -certfile out/ca1/cert_ca1 ^
  -signer out/%1/verified_cert_ra -out out/%1/verified_req_%1.der ^
  -outform der -purpose any 2> NUL

echo    8 extracting CSR(%1) from Signed(CSR(%1))

openssl req -in out/%1/verified_req_%1.der -inform der ^
  -out out/%1/verified_req_%1 -outform pem > NUL

echo             stored in out/%1/verified_req_%1.der

echo    9 extracting Cert(signer of Signed(CSR(%1))) 

call decode out/%1/verified_cert_ra > NUL

echo             stored in out/%1/verified_cert_ra.der

echo    10 validating Cert(signer of Signed(CSR(%1))).CertificatePolicies 

openssl x509 -in out/%1/verified_cert_ra -text -noout | findstr /C:"Polic"

echo    11 validating CSR(%1).challengePassword.info

openssl req -in out/%1/verified_req_%1 -inform pem ^
 -text -noout | findstr /C:"challenge"

echo    12 creating Cert(%1) 

openssl ca -name ca1 -batch -in out/%1/verified_req_%1 ^
  -key ca1ca1 -days %2 -extfile ./cfg/%1.cfg -extensions exts ^
  -out out/%1/tmp_cert_%1 -notext -utf8 2> NUL

call decode out/%1/tmp_cert_%1 > NUL

echo             stored in out/%1/tmp_cert_%1.der

echo    13 enveloping Cert(%1) for RA 

openssl cms -encrypt -in out/%1/tmp_cert_%1.der -binary -inform der ^
  -econtent_type pkcs7-data -belt-ctr256 -out out/%1/enveloped_cert_%1 ^
  -outform pem -recip out/ra/cert_ra

call decode out/%1/enveloped_cert_%1 > NUL

echo             stored in out/%1/enveloped_cert_%1.der

echo    14 recovering Enveloped(Cert(%1)) 

openssl cms -decrypt -in out/%1/enveloped_cert_%1 -inform pem ^
 -inkey out/ra/privkey_ra -out out/%1/cert_%1.der -outform der ^
 -passin pass:rarara

openssl x509 -in out/%1/cert_%1.der -inform der ^
  -out out/%1/cert_%1 -outform pem > NUL

call decode out/%1/cert_%1 > NUL

echo             stored in out/%1/cert_%1.der

