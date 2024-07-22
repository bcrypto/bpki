@echo off
rem ===========================================================================
rem \brief Запрос и ответ TSA = TimeStamp Authority
rem \project bpki/demo
rem \created 2018.01.10
rem \version 2024.07.22
rem \pre Выполнен скрипт setup.cmd.
rem \remark ТSA = СШВ = Служба штампов времени
rem \remark Выпускаются две пары "запрос - ответ": лаконичная и подробная.
rem В лаконичной паре заблокированы нонсы, сертификат TSA не включается в 
rem ответ. В подробной паре все наоборот.
rem \remark Ответ TSA представляет собой контейнер с двумя полями: 
rem   - cтатус обработки,
rem   - штамп времени -- контейнер типа SignedData. 
rem Штамп времени как SignedData включает 4 подписанных атрибута: contentType, 
rem MessageDigest, SigningCertificateV2, SigningTime.
rem Первые два атрибута обязательны по правилам СТБ 34.101.78-cms. 
rem Третий атрибут описывает хэш-значение сертификата TSA. 
rem Четвертый атрибут имеет мало смысла (время уже указано в штампе),
rem но подавить его через командную строку нельзя.
rem \remark По умолчанию вместо SigningCertificateV2 используется атрибут 
rem SigningCertificate, и этот атрибут строится с помощью хэш-функции sha1.
rem Для включения SigningCertificateV2 следует настроить конфигурационный 
rem файл: в поле ess_cert_id_alg секции [tsa] следует указать имя 
rem альтернативной хэш-функции.
rem ===========================================================================

echo == Testing TSA Services ==================================================

set OPENSSL_CONF=openssl.cfg
md out 2> nul
copy out\ca1\cert + out\tsa\cert out\tsa\chain > nul

echo -- 1 TSA Request1 ---------------------

openssl ts -query -data tsa.cmd -bash256 -out out/tsa/req1.tsq -no_nonce 2> nul

dumpasn1b -z -cdumpasn1by.cfg out/tsa/req1.tsq out/tsa/req1.txt 2> nul

echo stored in out/tsa/req1.tsq

echo -- 2 TSA Response1 --------------------

openssl ts -reply -queryfile out/tsa/req1.tsq ^
  -signer out/tsa/cert -passin pass:tsatsatsa -inkey out/tsa/privkey ^
  -out out/tsa/resp1.tsr -no_nonce 2> nul

dumpasn1b -z -cdumpasn1by.cfg out/tsa/resp1.tsr out/tsa/resp1.txt 2> nul

echo stored in out/tsa/resp1.tsr

echo -- 3 TSA Verify1 ----------------------

openssl ts -verify -queryfile out/tsa/req1.tsq -in out/tsa/resp1.tsr ^
  -CAfile out/ca0/cert -untrusted out/tsa/chain 2> nul

echo -- 4 TSA Request2 ---------------------

openssl ts -query -data tsa.cmd -bash512 -out out/tsa/req2.tsq -cert 2> nul

dumpasn1b -z -cdumpasn1by.cfg out/tsa/req2.tsq out/tsa/req2.txt 2> nul

echo stored in out/tsa/req2.tsq

echo -- 5 TSA Response2 --------------------

openssl ts -reply -queryfile out/tsa/req2.tsq ^
  -signer out/tsa/cert -passin pass:tsatsatsa -inkey out/tsa/privkey ^
  -out out/tsa/resp2.tsr 2> nul

dumpasn1b -z -cdumpasn1by.cfg out/tsa/resp2.tsr out/tsa/resp2.txt 2> nul

echo stored in out/tsa/resp2.tsr

echo -- 6 TSA Verify2 ----------------------

openssl ts -verify -data tsa.cmd -bash512 -in out/tsa/resp2.tsr ^
  -CAfile out/ca0/cert -untrusted out/ca1/cert 2> nul

openssl ts -verify -queryfile out/tsa/req2.tsq -in out/tsa/resp2.tsr ^
  -CAfile out/ca0/cert -untrusted out/ca1/cert 2> nul

echo == End ===================================================================
