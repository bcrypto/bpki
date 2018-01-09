@echo off

openssl asn1parse -in "%1" -inform pem -out "%1.der" > NUL
if %ERRORLEVEL% equ 0 goto Decode_Success
echo Processing %1... Failed
goto Decode_End

:Decode_Success

echo Processing %1... Ok
dumpasn1 "%1.der" > "%1.txt" 2> NUL

:Decode_End
