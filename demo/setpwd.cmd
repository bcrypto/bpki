@echo off
rem ===========================================================================
rem \brief Процесc Setpwd
rem \project bpki/demo
rem \created 2018.01.23
rem \version 2018.05.07
rem \params %1 -- конечный участник, %2 -- новый пароль.
rem \pre Имеется действительный сертификат ./out/%1/cert.
rem ===========================================================================

rem ===========================================================================

set OPENSSL_CONF=openssl.cfg
setlocal enableDelayedExpansion

if .%1. equ .. goto Usage
if not exist "./out/%1/cert" goto Usage
if .%2. equ .. goto Usage

echo == Setting password  ================================================

echo -- 1 formatting password

set newpwd=/RPWD:%2

echo result = %newpwd%

echo -- 2 creating ASN.1 object

openssl asn1parse -genstr "UTF8:%newpwd%" -out out/%1/setpwd.der > nul

dumpasn1b -z -cdumpasn1by.cfg out/%1/setpwd.der out/%1/setpwd.txt 2> nul

echo stored in out/%1/setpwd.der

echo -- 3 signing ASN.1 object

openssl cms -sign -signer out/%1/cert ^
  -inkey out/%1/privkey -passin pass:%1%1%1 ^
  -in out/%1/setpwd.der -binary -econtent_type bpki-ct-setpwd-req ^
  -out out/%1/signed_setpwd -outform pem -nodetach -nosmimecap

call decode out/%1/signed_setpwd > nul

echo stored in out/%1/signed_setpwd.der

echo -- 4 enveloping Signed(ASN1(newpwd)) for CA1

openssl cms -encrypt -in out/%1/signed_setpwd.der -inform der -binary ^
  -belt-cfb256 -out out/%1/enveloped_signed_setpwd ^ -outform pem ^
  -recip out/ca1/cert

call decode out/%1/enveloped_signed_setpwd > nul

echo stored in out/%1/enveloped_signed_setpwd.der

echo -- 5 Calculating reqid = hash(Enveloped(Signed(ASN1(newpwd))))

openssl dgst -belt-hash out/%1/enveloped_signed_setpwd.der ^
  -hex > out/%1/setpwd_reqid.txt 2> nul

set /p reqid=< out/%1/setpwd_reqid.txt
for /f "tokens=1-2 delims= " %%i in ("%reqid%") do set reqid=%%j

echo %reqid% > out/%1/setpwd_reqid.txt

echo stored in out/%1/setpwd_reqid.txt

echo -- 6 recovering Enveloped(Signed(ASN1(newpwd))) 

openssl cms -decrypt -in out/%1/enveloped_signed_setpwd -inform pem ^
  -inkey out/ca1/privkey -out out/%1/recovered_signed_setpwd.der ^
  -binary -passin pass:ca1ca1ca1 -debug_decrypt

openssl pkcs7 -in out/%1/recovered_signed_setpwd.der -inform der ^
  -out out/%1/recovered_signed_setpwd -outform pem > nul

call decode out/%1/recovered_signed_setpwd > nul

echo stored in out/%1/recovered_signed_setpwd.der

echo -- 7 verifying Signed(ASN1(newpwd)) 

copy out\ca0\cert + out\ca1\cert out\%1\chain > nul

openssl cms -verify -in out/%1/recovered_signed_setpwd -inform pem ^
  -CAfile out/%1/chain -signer out/%1/verified_cert ^
  -out out/%1/verified_setpwd.der -outform der -purpose any

echo -- 8 extracting ASN1(newpwd) from Signed(ASN1(newpwd))

echo stored in out/%1/verified_setpwd.der

echo -- 9 processing newpwd

openssl asn1parse -in out/%1/verified_setpwd.der ^
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

set /p reqid=< out/%1/setpwd_reqid.txt
set NL=^


rem don't delete empty lines above!
set resp=asn1=SEQUENCE:bpkiresp!NL!^
[bpkiresp]!NL!^
statusInfo=SEQUENCE:pkistatusinfo!NL!^
requestId=OCT:%reqid%!NL!^
[pkistatusinfo]!NL!^
status=INTEGER:0x00

echo !resp! > out/%1/setpwd_resp.cfg

openssl asn1parse -genconf out/%1/setpwd_resp.cfg ^
  -out out/%1/setpwd_resp.der > nul

dumpasn1b -z -cdumpasn1by.cfg out/%1/setpwd.der out/%1/setpwd.txt 2> nul

echo stored in out/%1/setpwd_resp.der

echo -- 12 signing BPKIResp(reqid) by agCA1

openssl cms -sign -signer out/agca1/cert ^
  -inkey out/agca1/privkey -passin pass:agca1agca1agca1 ^
  -in out/%1/setpwd_resp.der -binary -econtent_type bpki-ct-resp ^
  -out out/%1/signed_setpwd_resp -outform pem -nodetach -nosmimecap

call decode out/%1/signed_setpwd_resp > nul

echo stored in out/%1/signed_setpwd_resp.der

echo -- 13 validating Signed(BPKIResp(reqid))

openssl cms -verify -in out/%1/signed_setpwd_resp -inform pem ^
  -CAfile out/%1/chain -out nul -purpose any -noout

rem ===========================================================================

goto End

:Usage

echo Usage: setpwd.cmd ^<entity^> ^<newpwd^>
echo   \pre /out/entity/cert exists

:End