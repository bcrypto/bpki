#!/bin/bash

#rem ===========================================================================
#rem \brief Запрос и ответ сервера OCSP
#rem \project bpki/demo
#rem \created 2018.01.10
#rem \version 2018.01.23
#rem \pre Выполнен скрипт setup.cmd.
#rem \remark Выпускаются две пары "запрос - ответ". В первой паре
#rem запрашивается статус сертификата самого OCSP-сервера. Во второй паре:
#rem - статусы 2 нераспознаваемых сертификатов (действующие КУЦ и РУЦ);
#rem - статус сертификата TSA;
#rem - статусы несуществующих сертификатов по серийным номерам;
#rem - статус отозванного сертификата opra.
#rem ===========================================================================

echo "== Testing OCSP Services ================================================="

export OPENSSL_CONF=openssl.cfg
echo "-- 0 preparing dirs ($1)"

cd out
mkdir $1 2> /dev/null
cd ..

echo "-- 1 OCSP Request1 --------------------"

openssl ocsp -issuer out/ca1/cert -belt-hash -cert answers/$1/cert \
  -reqout out/$1/ocsp_req.der -no_nonce

#dumpasn1b -z -cdumpasn1by.cfg out/ocsp/req1.der out/ocsp/req1.txt 2> nul
source dump.sh out/$1/ocsp_req.der

echo "stored in out/$1/req1.der"
#
#echo -- 2 OCSP Response1 -------------------
#
#openssl ocsp -index out/ca1/index.txt -CA out/ca1/cert ^
#  -rsigner out/ocsp/cert -rkey out/ocsp/privkey_plain ^
#  -reqin out/ocsp/req1.der -respout out/ocsp/resp1.der -resp_no_certs
#
#dumpasn1b -z -cdumpasn1by.cfg out/ocsp/resp1.der out/ocsp/resp1.txt 2> nul
#
#echo stored in out/ocsp/resp1.der
#
#echo -- 3 OCSP Verify1 ---------------------
#
#openssl ocsp -issuer out/ca1/cert -cert out/ocsp/cert ^
#  -CAfile out/ca0/cert -VAfile out/ocsp/cert
#
#if %ERRORLEVEL% equ 0 (echo ok) else (echo failed)
#
#echo -- 4 OCSP Request2 --------------------
#
#openssl x509 -in legacy/kuc.cer -inform der -out out/ocsp/cert_kuc
#openssl x509 -in legacy/ruc.cer -inform der -out out/ocsp/cert_ruc
#
#openssl ocsp -issuer out/ca1/cert -bash384 ^
#  -cert out/tsa/cert ^
#  -cert out/ocsp/cert_kuc ^
#  -cert out/ocsp/cert_ruc ^
#  -serial -1 ^
#  -serial 23 ^
#  -cert out/opra/cert0 ^
#  -reqout out/ocsp/req2.der
#
#dumpasn1b -z -cdumpasn1by.cfg out/ocsp/req2.der out/ocsp/req2.txt 2> nul
#
#echo stored in out/ocsp/req2.der
#
#echo -- 5 OCSP Response2 -------------------
#
#openssl ocsp -index out/ca1/index.txt -CA out/ca1/cert ^
#  -rsigner out/ocsp/cert -rkey out/ocsp/privkey_plain ^
#  -reqin out/ocsp/req2.der -respout out/ocsp/resp2.der
#
#dumpasn1b -z -cdumpasn1by.cfg out/ocsp/resp2.der out/ocsp/resp2.txt 2> nul
#
#echo stored in out/ocsp/resp1.der
#
#echo -- 6 OCSP Verify2 ---------------------
#
#openssl ocsp -issuer out/ca1/cert -cert out/ocsp/cert ^
#  -CAfile out/ca0/cert -VAfile out/ocsp/cert
#
#if %ERRORLEVEL% equ 0 (echo ok) else (echo failed)
#
#echo == End ===================================================================
