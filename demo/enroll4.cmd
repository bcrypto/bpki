@echo off
rem ===========================================================================
rem \brief Процесc Enroll4
rem \project bpki/demo
rem \params %1  конечный участник, %2  срок действия (дней)
rem \pre Предварительно выполнен setup.cmd
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

echo    3 enveloping Signed(CSR(%1)) for CA1 

openssl cms -encrypt -in out/%1/req_%1 -econtent_type pkcs7-data ^
  -inform PEM -belt-cfb256 -out out/%1/enveloped_req_%1 ^
  -outform PEM -recip out/ca1/cert_ca1

call decode out/%1/enveloped_req_%1 > NUL

echo             stored in out/%1/enveloped_req_%1.der

echo    4 calculating a ticket = hash(Enveloped(CSR(%1)))

openssl dgst -belt-hash -binary -out out/%1/req_ticket_%1.bin ^
out/%1/enveloped_req_%1.der 2> NUL

echo             stored in out/%1/req_ticket_%1.bin

echo    5 recovering Enveloped(CSR(%1))

openssl cms -decrypt -in out/%1/enveloped_req_%1.der -inform der ^
 -inkey out/ca1/privkey_ca1 -out out/%1/recovered_req_%1 -outform pem ^
 -passin pass:ca1ca1

call decode out/%1/recovered_req_%1 > NUL

echo             stored in out/%1/recovered_req_%1.der

echo    6 validating CSR(%1).challengePassword.epwd

openssl req -in out/%1/recovered_req_%1 -text -noout | findstr /C:"challenge"

echo    7 creating Cert(%1)

openssl ca -name ca1 -batch -in out/%1/recovered_req_%1 -key ca1ca1 -days %2 ^
  -extfile ./cfg/%1.cfg -extensions exts -out out/%1/tmp_cert_%1 -notext ^
  -utf8 2> NUL

call decode out/%1/tmp_cert_%1 > NUL

echo             stored in out/%1/tmp_cert_%1.der

echo    8 enveloping Cert(%1) for %1

openssl cms -encrypt -in out/%1/tmp_cert_%1 -econtent_type pkcs7-data ^
  -inform PEM -belt-ctr256 -out out/%1/enveloped_cert_%1 ^
  -outform PEM -recip out/%1/tmp_cert_%1

call decode out/%1/enveloped_cert_%1 > NUL

echo             stored in out/%1/enveloped_cert_%1.der

echo    9 recovering Enveloped(Cert(%1)) 

openssl cms -decrypt -in out/%1/enveloped_cert_%1.der -inform der ^
 -inkey out/%1/privkey_%1 -out out/%1/cert_%1 -outform pem ^
 -passin pass:%1%1%1

call decode out/%1/cert_%1 > NUL

echo             stored in out/%1/cert_%1.der

