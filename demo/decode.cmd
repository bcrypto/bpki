@echo off
rem ===========================================================================
rem \brief Декодирование файла формата base64(der(%1))
rem \project bpki/demo
rem \created 2018.01.10
rem \version 2018.01.23
rem \params %1 -- файл в кодировке der
rem \remark Сначала создается файл %1.der = der(%1), затем файл 
rem %1.txt = dumpasn1(%.der)
rem \remark dumpasn1 -- это популярная программа дампа контейнеров ACH.1
rem \thanks (c) Peter Gutmann <pgut001@cs.auckland.ac.nz>
rem ===========================================================================

set OPENSSL_CONF=openssl.cfg

openssl asn1parse -in "%1" -inform pem -out "%1.der" > NUL
if %ERRORLEVEL% equ 0 goto Decode_Success
echo Processing %1... Failed
goto Decode_End

:Decode_Success

echo Processing %1... Ok

dumpasn1b -z -cdumpasn1by.cfg "%1.der" "%1.txt" 2> NUL

exit /b 0

:Decode_End
exit /b 1
