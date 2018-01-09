@echo off
set OPENSSL_CONF=openssl.cfg

echo == Engine Info ===========================================================

openssl version
openssl engine -c -t bee2evp

echo == End ===================================================================
