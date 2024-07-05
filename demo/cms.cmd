@echo off
rem ===========================================================================
rem \brief Проверка и демонстрация возможностей OpenSSL[bee2evp]
rem \project bpki/demo
rem \created 2024.07.05
rem \version 2024.07.05
rem \pre Выполнен скрипт setup.cmd.
rem \pre Выполнен скрипт enroll.cmd.
rem ===========================================================================

set OPENSSL_CONF=openssl.cfg
copy out\ca0\cert + out\ca1\cert out\np\chain > nul

echo == Testing CMS ===========================================================

echo ---- CMS Sign ------------------------------------------------------------

echo | set /p="Creating signed(cms.cmd)... "

openssl cms -sign -binary -in cms.cmd -signer out/np/cert ^
  -inkey out/np/privkey -passin pass:npnpnp ^
  -out out/cms_signed -outform pem -nodetach -nosmimecap

if %ERRORLEVEL% equ 0 (echo ok) else (echo failed)

echo ---- CMS Verify ----------------------------------------------------------

openssl cms -verify -binary -in out/cms_signed -inform pem ^
  -CAfile out/np/chain -signer out/np/cert -out out/verified_cms.cmd ^
  -purpose any

echo ---- CMS Sign Detached ---------------------------------------------------

echo | set /p="Creating sig(cms.cmd)... "

openssl cms -sign -binary -in cms.cmd -signer out/np/cert ^
  -inkey out/np/privkey -passin pass:npnpnp ^
  -out out/cms_sig -outform pem -nosmimecap

if %ERRORLEVEL% equ 0 (echo ok) else (echo failed)

echo ---- CMS Verify Detached -------------------------------------------------

openssl cms -verify -binary -in out/cms_sig -inform pem ^
  -content cms.cmd -CAfile out/np/chain -signer out/np/cert > nul

echo ---- CMS Encrypt ---------------------------------------------------------

echo | set /p="Encrypting cms.cmd... "

openssl cms -encrypt -binary -belt-ctr256 -in cms.cmd -out out/cms.encr ^
  out/np/cert

if %ERRORLEVEL% equ 0 (echo ok) else (echo failed)

echo ---- CMS Decrypt ---------------------------------------------------------

echo | set /p="Decrypting cms.cmd... "

openssl cms -decrypt -binary -in out/cms.encr -recip out/np/cert ^
  -inkey out/np/privkey -passin pass:npnpnp -out out/cms.decr

if %ERRORLEVEL% equ 0 (echo ok) else (echo failed)

echo | set /p="Comparing decr(encr(cms.cmd)) with cms.cmd... "

fc /b cms.cmd out\cms.decr > nul

if %ERRORLEVEL% equ 0 (echo ok) else (echo failed)
