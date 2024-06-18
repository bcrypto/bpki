@echo off
rem ===========================================================================
rem \brief Проверка и демонстрация возможностей OpenSSL[bee2evp]
rem \project bpki/demo
rem \created 2018.01.10
rem \version 2018.01.23
rem ===========================================================================

set OPENSSL_CONF=openssl.cfg

echo == Engine Info ===========================================================

openssl version
openssl engine -c -t bee2evp
echo == End ===================================================================

