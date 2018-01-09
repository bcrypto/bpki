@echo off

echo == Initializing PKI ======================================================

set OPENSSL_CONF=openssl.cfg
md out 2> NUL

echo[
echo -- 1 Generating Params ---------------------------------------------------

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve256v1 ^
  -out out/params256

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve384v1 ^
  -out out/params384

openssl genpkey -genparam -algorithm bign -pkeyopt params:bign-curve512v1 ^
  -out out/params512

openssl pkeyparam -in out/params256 -noout -text
openssl pkeyparam -in out/params384 -noout -text
openssl pkeyparam -in out/params512 -noout -text

echo[
echo -- 2 Creating CA0 (Root CA) ----------------------------------------------

cd out
md ca0 2> NUL
cd ca0
type nul > index.txt
md certs 2> NUL
cd ..
cd ..

openssl req -new -utf8 -nameopt multiline,utf8 -newkey bign:out/params512 ^
  -config ./cfg/ca0.cfg -keyout out/ca0/privkey_ca0 ^
  -out out/ca0/req_ca0 -passout pass:ca0ca0 -batch

call decode out/ca0/req_ca0

openssl x509 -req -extfile ./cfg/ca0.cfg -extensions exts ^
  -in out/ca0/req_ca0 -signkey out/ca0/privkey_ca0 -passin pass:ca0ca0 ^
  -out out/ca0/cert_ca0

call decode out/ca0/cert_ca0

echo[
echo -- 3 Creating CA1 (Republican CA) ----------------------------------------

cd out
md ca1 2> NUL
cd ca1
type nul > index.txt
md certs 2> NUL
cd ..
cd ..

openssl req -new -utf8 -nameopt multiline,utf8 -newkey bign:out/params384 ^
  -config ./cfg/ca1.cfg -keyout out/ca1/privkey_ca1 -out out/ca1/req_ca1 ^
  -passout pass:ca1ca1 -batch

call decode out/ca1/req_ca1

openssl ca -name ca0 -create_serial -batch -in out/ca1/req_ca1 -key ca0ca0 ^
  -extfile ./cfg/ca1.cfg -extensions exts -out out/ca1/cert_ca1 -notext ^
  -utf8 2> NUL

call decode out/ca1/cert_ca1

echo[
echo -- 4 Creating CA2 (Subordinate CA) ---------------------------------------

cd out
md ca2 2> NUL
cd ca2
type nul > index.txt
md certs 2> NUL
cd ..
cd ..

openssl req -new -utf8 -nameopt multiline,utf8 -newkey bign:out/params256 ^
  -config ./cfg/ca2.cfg -keyout out/ca2/privkey_ca2 -out out/ca2/req_ca2 ^
  -passout pass:ca2ca2 -batch

call decode out/ca2/req_ca2

openssl ca -name ca1 -create_serial -batch -in out/ca2/req_ca2 -key ca1ca1 ^
  -extfile ./cfg/ca2.cfg -extensions exts -out out/ca2/cert_ca2 -notext ^
  -utf8 2> NUL

call decode out/ca2/cert_ca2

echo[
echo -- 5 Creating End Entities -----------------------------------------------

call :Create aa
call :Create ra
call :Create ocsp
call :Create tsa
call :Create dvcs
call :Create ids
call :Create tls
call :Create np
call :Create fnp
call :Create lr
call :Create acd

goto End

:Create

cd out
md %1 2> NUL
cd ..

openssl req -new -utf8 -nameopt multiline,utf8 -newkey bign:out/params256 ^
  -config ./cfg/%1.cfg -keyout out/%1/privkey_%1 -reqexts reqexts ^
  -out out/%1/req_%1 -passout pass:%1%1%1 -batch 2> NUL

if %ERRORLEVEL% neq 0 goto Create_Error

call decode out/%1/req_%1 > NUL

openssl ca -name ca1 -batch -in out/%1/req_%1 -key ca1ca1 ^
  -extfile ./cfg/%1.cfg -extensions exts -out out/%1/cert_%1 -notext ^
  -utf8 2> NUL

if %ERRORLEVEL% neq 0 goto Create_Error

call decode out/%1/cert_%1 > NUL

echo Creating %1... Ok

goto Create_End

:Create_Error
echo Creating %1... Failed

:Create_End
exit /b

:End

echo == End ===================================================================
