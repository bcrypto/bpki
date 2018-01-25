@echo off
rem ===========================================================================
rem \brief Процесc Chpwd
rem \project bpki/demo
rem \created 2018.01.23
rem \version 2018.01.25
rem \params %1 -- конечный участник, %2 -- новый пароль.
rem \pre Имеется действительный сертификат ./out/%1/cert.
rem ===========================================================================

rem ===========================================================================

set OPENSSL_CONF=openssl.cfg
setlocal enableDelayedExpansion

if .%1. equ .. goto Usage
if not exist "./out/%1/cert" goto Usage
if .%2. equ .. goto Usage

echo == Changing revoke password  =============================================

echo -- 1 formatting revoke password

set newpwd=/RPWD:%2

echo result = %newpwd%

echo -- 2 creating ASN.1 object

openssl asn1parse -genstr "UTF8:%newpwd%" -out out/%1/chpwd.der > nul

dumpasn1b -z -cdumpasn1by.cfg out/%1/chpwd.der out/%1/chpwd.txt 2> nul

echo stored in out/%1/chpwd.der

echo -- 3 signing ASN.1 object

openssl cms -sign -signer out/%1/cert ^
  -inkey out/%1/privkey -passin pass:%1%1%1 ^
  -in out/%1/chpwd.der -binary -econtent_type pkcs7-data ^
  -out out/%1/signed_chpwd -outform pem -nodetach -noattr

call decode out/%1/signed_chpwd > nul

echo stored in out/%1/signed_chpwd.der

echo -- 4 enveloping Signed(ASN1(newpwd)) for CA1

openssl cms -encrypt -in out/%1/signed_chpwd.der -inform der -binary ^
  -belt-cfb256 -out out/%1/enveloped_signed_chpwd ^ -outform pem ^
  -recip out/ca1/cert -keyid

call decode out/%1/enveloped_signed_chpwd > nul

echo stored in out/%1/enveloped_signed_chpwd.der

echo -- 5 Calculating reqid = hash(Enveloped(Signed(ASN1(newpwd))))

openssl dgst -belt-hash out/%1/enveloped_signed_chpwd.der ^
  -hex > out/%1/chpwd_reqid.txt 2> nul

set /p reqid=< out/%1/chpwd_reqid.txt
for /f "tokens=1-2 delims= " %%i in ("%reqid%") do set reqid=%%j

echo %reqid% > out/%1/chpwd_reqid.txt

echo stored in out/%1/chpwd_reqid.txt

echo -- 6 recovering Enveloped(Signed(ASN1(newpwd))) 

openssl cms -decrypt -in out/%1/enveloped_signed_chpwd -inform pem ^
  -inkey out/ca1/privkey -out out/%1/recovered_signed_chpwd.der ^
  -binary -passin pass:ca1ca1ca1

openssl pkcs7 -in out/%1/recovered_signed_chpwd.der -inform der ^
  -out out/%1/recovered_signed_chpwd -outform pem > nul

call decode out/%1/recovered_signed_chpwd > nul

echo stored in out/%1/recovered_signed_chpwd.der

echo -- 7 verifying Signed(ASN1(newpwd)) 

copy out\ca0\cert + out\ca1\cert out\%1\chain > nul

openssl cms -verify -in out/%1/recovered_signed_chpwd -inform pem ^
  -CAfile out/%1/chain -certfile out/ca1/cert ^
  -signer out/%1/verified_cert -out out/%1/verified_chpwd.der ^
  -outform der -purpose any

echo -- 8 extracting ASN1(newpwd) from Signed(ASN1(newpwd))

echo stored in out/%1/verified_chpwd.der

echo -- 9 processing newpwd

openssl asn1parse -in out/%1/verified_chpwd.der ^
  -inform der > out/ca1/newpwd_%1.txt

set /p newpwd=< out/ca1/newpwd_%1.txt

for /f "tokens=1-2 delims=/" %%i in ("%newpwd%") do set newpwd=%%j
for /f "tokens=1-2 delims=:" %%i in ("%newpwd%") do (
  set pwd1=%%i
  set pwd2=%%j)

echo %pwd1% = %pwd2%

set newpwd=/%pwd1%:%pwd2%

echo stored in out/ca1/newpwd_%1.txt

echo -- 11 creating BPKIResp(reqid)

set /p reqid=< out/%1/chpwd_reqid.txt
set NL=^


rem don't delete empty lines above!
set resp=asn1=SEQUENCE:bpkiresp!NL!^
[bpkiresp]!NL!^
statusInfo=SEQUENCE:pkistatusinfo!NL!^
requestId=OCT:%reqid%!NL!^
[pkistatusinfo]!NL!^
status=INTEGER:0x00

echo !resp! > out/%1/chpwd_resp.cfg

openssl asn1parse -genconf out/%1/chpwd_resp.cfg ^
  -out out/%1/chpwd_resp.der > nul

dumpasn1b -z -cdumpasn1by.cfg out/%1/chpwd.der out/%1/chpwd.txt 2> nul

echo stored in out/%1/chpwd_resp.der

echo -- 12 signing BPKIResp(reqid) by CA1

openssl cms -sign -signer out/ca1/cert ^
  -inkey out/ca1/privkey -passin pass:ca1ca1ca1 ^
  -in out/%1/chpwd_resp.der -binary -econtent_type pkcs7-data ^
  -out out/%1/signed_chpwd_resp -outform pem -nodetach -noattr -nocerts

call decode out/%1/signed_chpwd_resp > nul

echo stored in out/%1/signed_chpwd_resp.der

echo -- 13 validating Signed(BPKIResp(reqid))

openssl cms -verify -in out/%1/signed_chpwd_resp -inform pem ^
  -CAfile out/ca0/cert -certfile out/ca1/cert ^
  -out nul -purpose any -noout 

pause

rem ===========================================================================

goto End

:Usage

echo Usage: chpwd.cmd ^<entity^> ^<newpwd^>
echo   \pre /out/entity/cert esists

:End