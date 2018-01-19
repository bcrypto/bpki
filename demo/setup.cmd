@echo off
rem ===========================================================================
rem \brief Создание модельных УЦ и выпуск модельных сертификатов
rem \project bpki/demo
rem \remark Контейнеры с личными ключами конфигурируются по правилам BPKI.
rem \thanks[GenTime] https://stackoverflow.com/questions/203090/how-do-i-get-
rem current-datetime-on-the-windows-command-line-in-a-suitable-format
rem ===========================================================================

echo == Initializing PKI ======================================================

set OPENSSL_CONF=openssl.cfg
md out 2> NUL

for /F "usebackq tokens=1,2 delims==" %%i in (`wmic os get LocalDateTime /VALUE 2^>NUL`) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j
set ldt=%ldt:~0,14%Z

echo GenTime = %ldt%

echo == 1 Generating Params ===================================================

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve256v1 ^
  -out out/params256

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve384v1 ^
  -out out/params384

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve512v1 ^
  -out out/params512

openssl pkeyparam -in out/params256 -noout -text
openssl pkeyparam -in out/params384 -noout -text
openssl pkeyparam -in out/params512 -noout -text

echo == 2 Creating CA0 (Root CA) ==============================================

cd out
md ca0 2> NUL
cd ca0
type nul > index.txt
echo 01 > crlnumber
md certs 2> NUL
cd ..
cd ..

openssl genpkey -paramfile out/params512 ^
  -pkeyopt enc_params:specified -pkeyopt enc_params:cofactor ^
  -out out/ca0/privkey_ca0_plain

call decode out/ca0/privkey_ca0_plain > NUL

openssl pkcs8 -in out/ca0/privkey_ca0_plain -topk8 ^
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 ^
  -passout pass:ca0ca0ca0 -out out/ca0/privkey_ca0

call decode out/ca0/privkey_ca0 > NUL

openssl req -new -utf8 -nameopt multiline,utf8 -config ./cfg/ca0.cfg ^
  -key out/ca0/privkey_ca0 -passin pass:ca0ca0ca0 -out out/ca0/req_ca0 -batch

call decode out/ca0/req_ca0 > NUL

openssl x509 -req -extfile ./cfg/ca0.cfg -extensions exts ^
  -in out/ca0/req_ca0 -signkey out/ca0/privkey_ca0 -passin pass:ca0ca0ca0 ^
  -out out/ca0/cert_ca0

call decode out/ca0/cert_ca0 > NUL

echo == 3 Creating CA1 (Republican CA) ========================================

cd out
md ca1 2> NUL
cd ca1
type nul > index.txt
echo 01 > crlnumber
md certs 2> NUL
cd ..
cd ..

openssl genpkey -paramfile out/params384 ^
  -pkeyopt enc_params:specified -out out/ca1/privkey_ca1_plain

call decode out/ca1/privkey_ca1_plain > NUL

openssl pkcs8 -in out/ca1/privkey_ca1_plain -topk8 ^
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 ^
  -passout pass:ca1ca1ca1 -out out/ca1/privkey_ca1

call decode out/ca1/privkey_ca1 > NUL

openssl req -new -utf8 -nameopt multiline,utf8 -config ./cfg/ca1.cfg ^
  -key out/ca1/privkey_ca1 -passin pass:ca1ca1ca1 -out out/ca1/req_ca1 -batch

call decode out/ca1/req_ca1 > NUL

openssl ca -name ca0 -create_serial -batch -in out/ca1/req_ca1 ^
  -key ca0ca0ca0 -extfile ./cfg/ca1.cfg -extensions exts ^
  -out out/ca1/cert_ca1 -notext -utf8 2> NUL

call decode out/ca1/cert_ca1 > NUL

echo == 4 Creating CA2 (Subordinate CA) =======================================

cd out
md ca2 2> NUL
cd ca2
type nul > index.txt
echo 01 > crlnumber
md certs 2> NUL
cd ..
cd ..

openssl genpkey -paramfile out/params256 -pkeyopt enc_params:cofactor ^
-out out/ca2/privkey_ca2_plain

call decode out/ca2/privkey_ca2_plain > NUL

openssl pkcs8 -in out/ca2/privkey_ca2_plain -topk8 ^
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 ^
  -passout pass:ca2ca2ca2 -out out/ca2/privkey_ca2

call decode out/ca1/privkey_ca1 > NUL

openssl req -new -utf8 -nameopt multiline,utf8 -config ./cfg/ca2.cfg ^
  -key out/ca2/privkey_ca2 -passin pass:ca2ca2ca2 -out out/ca2/req_ca2 -batch

call decode out/ca2/req_ca2 > NUL

openssl ca -name ca1 -create_serial -batch -in out/ca2/req_ca2 ^
  -key ca1ca1ca1 -extfile ./cfg/ca2.cfg -extensions exts ^
  -out out/ca2/cert_ca2 -notext -utf8 2> NUL

call decode out/ca2/cert_ca2 > NUL

echo == 5 Creating End Entities ===============================================

call :Create aa 1825
call :Create ra 1825
call :Create ocsp 1095
call :Create tsa 1825
call :Create dvcs 1825
call :Create ids 1095
call :Create tls 1095
call :Create opra 730

echo == 6 Revoking opra (for OCSP testing) ====================================

copy /b /y out\opra\cert_opra.* out\opra\cert_opra0.* > NUL

openssl ca -gencrl -name ca1 -key ca1ca1ca1 -crldays 1 -crlhours 6 ^
  -crlexts crlexts -out out/ca1/crl1 -batch 2> NUL

call decode out/ca1/crl1 > NUL

openssl ca -revoke out/opra/cert_opra0 -name ca1 -key ca1ca1ca1 ^
  -crl_reason keyCompromise -crl_compromise %ldt% -batch

openssl ca -gencrl -name ca1 -key ca1ca1ca1 -crlhours 1 ^
  -crlexts crlexts -out out/ca1/crl2 -batch 2> NUL

call decode out/ca1/crl2 > NUL

echo == 7 Creating opra again =================================================

call :Create opra 730

goto End

:Create

cd out
md %1 2> NUL
cd ..

openssl genpkey -paramfile out/params256 -out out/%1/privkey_%1_plain

call decode out/%1/privkey_%1_plain > NUL

openssl pkcs8 -in out/%1/privkey_%1_plain -topk8 ^
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 ^
  -passout pass:%1%1%1 -out out/%1/privkey_%1

call decode out/%1/privkey_%1 > NUL

openssl req -new -utf8 -nameopt multiline,utf8 -config ./cfg/%1.cfg ^
  -key out/%1/privkey_%1 -passin pass:%1%1%1 -out out/%1/req_%1 -batch

if %ERRORLEVEL% neq 0 goto Create_Error

call decode out/%1/req_%1 > NUL

openssl ca -name ca1 -batch -in out/%1/req_%1 -key ca1ca1ca1 -days %2 ^
  -extfile ./cfg/%1.cfg -extensions exts -out out/%1/cert_%1 -notext ^
  -utf8 2> NUL

if %ERRORLEVEL% neq 0 goto Create_Error

call decode out/%1/cert_%1 > NUL

echo Creating %1... Ok

goto Create_End

:Create_Error
echo Creating %1... Failed
exit /b 1

:Create_End
exit /b 0

:End

echo == End ===================================================================
