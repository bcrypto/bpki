@echo off
rem ===========================================================================
rem \brief Процесc Enroll1
rem \project bpki/demo
rem \params %1 -- конечный участник, %2 -- срок действия (дней).
rem \pre Имеется конфигурационный файл ./cfg/%1.cfg.
rem \post Сертификат out/%1/cert_%1 и промежуточные объекты.
rem ===========================================================================

set OPENSSL_CONF=openssl.cfg

echo    1 preparing dirs 

cd out
md %1 2> NUL
cd ..

echo    2 generating privkey(%1) 

openssl genpkey -paramfile out/params256 -out out/%1/privkey_%1_pre ^
  -pass pass:%1%1%1

openssl pkcs8 -in out/%1/privkey_%1_pre -passin pass:%1%1%1 -topk8 ^
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 ^
  -passout pass:%1%1%1 -out out/%1/privkey_%1

del /q out\%1\privkey_%1_pre > NUL
call decode out/%1/privkey_%1 > NUL

echo             stored in out/%1/privkey_%1.der

echo    3 creating CSR(%1) 

openssl req -new -utf8 -nameopt multiline,utf8 -newkey bign:out/params256 ^
  -config ./cfg/%1.cfg -keyout out/%1/privkey_%1 -reqexts reqexts ^
  -out out/%1/req_%1 -passout pass:%1%1%1 -batch 2> NUL

call decode out/%1/req_%1 > NUL

echo             stored in out/%1/req_%1.der

echo    4 signing CSR(%1) by opRA 

openssl cms -sign -signer out/opra/cert_opra ^
  -inkey out/opra/privkey_opra -passin pass:opraopraopra ^
  -in out/%1/req_%1.der -binary -econtent_type pkcs7-data ^
  -out out/%1/signed_req_%1 -outform pem -nodetach -noattr

call decode out/%1/signed_req_%1 > NUL

echo             stored in out/%1/signed_req_%1.der

echo    5 enveloping Signed(CSR(%1)) for CA1 

openssl cms -encrypt -in out/%1/signed_req_%1.der -inform der -binary ^
  -belt-cfb256 -out out/%1/enveloped_signed_req_%1 ^ -outform pem ^
  -recip out/ca1/cert_ca1 -keyid

call decode out/%1/enveloped_signed_req_%1 > NUL

echo             stored in out/%1/enveloped_signed_req_%1.der

echo    6 calculating a ticket = hash(Enveloped(Signed(CSR(%1)))) 

openssl dgst -belt-hash -binary -out out/%1/req_ticket_%1.bin ^
out/%1/enveloped_signed_req_%1.der 2> NUL

echo             stored in out/%1/req_ticket_%1.bin

echo    7 recovering Enveloped(Signed(CSR(%1))) 

openssl cms -decrypt -in out/%1/enveloped_signed_req_%1 -inform pem ^
  -inkey out/ca1/privkey_ca1 -out out/%1/recovered_signed_req_%1.der ^
  -binary -passin pass:ca1ca1ca1

openssl pkcs7 -in out/%1/recovered_signed_req_%1.der -inform der ^
  -out out/%1/recovered_signed_req_%1 -outform pem > NUL

call decode out/%1/recovered_signed_req_%1 > NUL

echo             stored in out/%1/recovered_signed_req_%1.der

echo    8 verifying Signed(CSR(%1)) 

copy out\ca0\cert_ca0 + out\ca1\cert_ca1 out\%1\chain_opra > NUL

openssl cms -verify -in out/%1/recovered_signed_req_%1 -inform pem ^
  -CAfile out/%1/chain_opra -certfile out/ca1/cert_ca1 ^
  -signer out/%1/verified_cert_opra -out out/%1/verified_req_%1.der ^
  -outform der -purpose any 2> NUL

echo    9 extracting CSR(%1) from Signed(CSR(%1))

openssl req -in out/%1/verified_req_%1.der -inform der ^
  -out out/%1/verified_req_%1 -outform pem > NUL

echo             stored in out/%1/verified_req_%1.der

echo    10 extracting Cert(signer of Signed(CSR(%1))) 

call decode out/%1/verified_cert_opra > NUL

echo             stored in out/%1/verified_cert_opra.der

echo    11 validating Cert(signer of Signed(CSR(%1))).CertificatePolicies 

openssl x509 -in out/%1/verified_cert_opra -text -noout | findstr /C:"Polic"

echo    12 processing CSR(%1).challengePassword 

openssl req -in out/%1/verified_req_%1 -inform pem ^
 -text -noout | findstr /C:"challenge"

echo    13 creating Cert(%1) 

openssl ca -name ca1 -batch -in out/%1/verified_req_%1 ^
  -key ca1ca1ca1 -days %2 -extfile ./cfg/%1.cfg -extensions exts ^
  -out out/%1/tmp_cert_%1 -notext -utf8 2> NUL

call decode out/%1/tmp_cert_%1 > NUL

echo             stored in out/%1/tmp_cert_%1.der

echo    14 enveloping Cert(%1) for opRA 

openssl cms -encrypt -in out/%1/tmp_cert_%1.der -binary -inform der ^
  -econtent_type pkcs7-data -belt-ctr256 -out out/%1/enveloped_cert_%1 ^
  -outform pem -recip out/opra/cert_opra -keyid

call decode out/%1/enveloped_cert_%1 > NUL

echo             stored in out/%1/enveloped_cert_%1.der

echo    15 recovering Enveloped(Cert(%1)) 

openssl cms -decrypt -in out/%1/enveloped_cert_%1 -inform pem ^
 -inkey out/opra/privkey_opra -out out/%1/cert_%1.der -outform der ^
 -passin pass:opraopraopra

openssl x509 -in out/%1/cert_%1.der -inform der ^
  -out out/%1/cert_%1 -outform pem > NUL

call decode out/%1/cert_%1 > NUL

echo             stored in out/%1/cert_%1.der

