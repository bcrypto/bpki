@echo off
rem ===========================================================================
rem \brief Процесc Enroll4
rem \project bpki/demo
rem \created 2018.01.10
rem \version 2018.01.25
rem \params %1 -- конечный участник, %2 -- срок действия (дней).
rem \pre Имеется конфигурационный файл ./cfg/%1.cfg.
rem \post Сертификат out/%1/cert и промежуточные объекты.
rem ===========================================================================

set OPENSSL_CONF=openssl.cfg

echo -- 1 preparing dirs 

if .%1. equ .. goto Usage
if not exist "./cfg/%1.cfg" goto Usage
if .%2. equ .. goto Usage

cd out
md %1 2> nul
cd ..

echo -- 2 generating privkey(%1) 

openssl genpkey -paramfile out/params256 -out out/%1/privkey_pre ^
  -pass pass:%1%1%1

openssl pkcs8 -in out/%1/privkey_pre -passin pass:%1%1%1 -topk8 ^
  -v2 belt-kwp256 -v2prf belt-hmac -iter 10000 ^
  -passout pass:%1%1%1 -out out/%1/privkey

del /q out\%1\privkey_pre > nul
call decode out/%1/privkey > nul

echo stored in out/%1/privkey.der

echo -- 3 creating CSR(%1) 

openssl req -new -utf8 -nameopt multiline,utf8 -newkey bign:out/params256 ^
  -config ./cfg/%1.cfg -keyout out/%1/privkey -reqexts reqexts ^
  -out out/%1/csr -passout pass:%1%1%1 -batch 2> nul

call decode out/%1/csr > nul

echo stored in out/%1/csr.der

echo -- 4 enveloping CSR(%1) for CA1 

openssl cms -encrypt -in out/%1/csr.der -econtent_type pkcs7-data ^
  -binary -belt-cfb256 -out out/%1/enveloped_csr ^
  -outform pem -recip out/ca1/cert -keyid

call decode out/%1/enveloped_csr > nul

echo stored in out/%1/enveloped_csr.der

echo -- 5 calculating reqid = hash(Enveloped(CSR(%1)))

openssl dgst -belt-hash out/%1/enveloped_csr.der ^
  -hex > out/%1/csr_reqid.txt 2> nul

set /p reqid=< out/%1/csr_reqid.txt
for /f "tokens=1-2 delims= " %%i in ("%reqid%") do set reqid=%%j

echo %reqid% > out/%1/csr_reqid.txt

echo stored in out/%1/csr_reqid.txt

echo -- 6 recovering Enveloped(CSR(%1))

openssl cms -decrypt -in out/%1/enveloped_csr -inform pem ^
 -inkey out/ca1/privkey -out out/%1/recovered_csr.der -outform der ^
 -passin pass:ca1ca1ca1

openssl req -in out/%1/recovered_csr.der -inform der ^
  -out out/%1/recovered_csr -outform pem > nul

call decode out/%1/recovered_csr > nul

echo stored in out/%1/recovered_csr.der

echo -- 7 validating CSR(%1).challengePassword.epwd

openssl req -in out/%1/recovered_csr -text ^
  -noout | findstr /C:"challenge" > out/ca1/pwd_%1.txt

set /p pwd=< out/ca1/pwd_%1.txt

for /f "tokens=1-7 delims=:/" %%i in ("%pwd%") do (
  set pwd1=%%j
  set pwd2=%%k
  set pwd3=%%l
  set pwd4=%%m
  set pwd5=%%n
  set pwd6=%%o)

if .%pwd1%. neq .. (
  echo %pwd1% = %pwd2%
  set pwd=/%pwd1%:%pwd2%)

if .%pwd4%. neq .. (
  echo %pwd3% = %pwd4%
  set pwd=%pwd%/%pwd3%:%pwd4%)

if .%pwd6%. neq .. (
  echo %pwd5% = %pwd6%
  set pwd=/%pwd5%:%pwd6%)

echo %pwd% > out/ca1/pwd_%1.txt

echo stored in out/ca1/pwd_%1.txt

echo -- 8 creating Cert(%1)

openssl ca -name ca1 -batch -in out/%1/recovered_csr -key ca1ca1ca1 ^
  -days %2 -extfile ./cfg/%1.cfg -extensions exts -out out/%1/tmp_cert ^
  -notext -utf8 2> nul

call decode out/%1/tmp_cert > nul

echo stored in out/%1/tmp_cert.der

echo -- 9 enveloping Cert(%1) for %1

openssl cms -encrypt -in out/%1/tmp_cert.der -inform der -binary ^
  -econtent_type pkcs7-data -belt-ctr256 -out out/%1/enveloped_cert ^
  -outform pem -recip out/%1/tmp_cert -keyid

call decode out/%1/enveloped_cert > nul

echo stored in out/%1/enveloped_cert.der

echo -- 10 recovering Enveloped(Cert(%1)) 

openssl cms -decrypt -in out/%1/enveloped_cert -inform pem ^
  -inkey out/%1/privkey -passin pass:%1%1%1 ^
  -out out/%1/cert.der -outform der

openssl x509 -in out/%1/cert.der -inform der ^
  -out out/%1/cert -outform pem > nul

call decode out/%1/cert > nul

echo stored in out/%1/cert.der

rem ===========================================================================

goto End

:Usage
echo Usage: enroll4.cmd ^<entity^> ^<days^> 
echo   \pre ./cfg/entity.cfg exists

:End