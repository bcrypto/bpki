@echo off
rem ===========================================================================
rem \brief Запрос и ответ TSA = TimeStamp Authority
rem \project bpki/demo
rem \remark ТSA = СШВ = Служба штампов времени
rem \remark Выпускаются две пары "запрос - ответ": лаконичная и подробная.
rem В лаконичной паре заблокированы нонсы, сертификат TSA не включается в 
rem ответ. В подробной паре все наоборот.
rem \remark Ответ TSA представляет собой контейнер с двумя полями: 
rem   - cтатус обработки,
rem   - штамп времени -- контейнер SignedData. 
rem SignedData включает 4 подписанных атрибута: contentType, 
rem MessageDigest, SigningCertificate, SigningTime. 
rem Первые два атрибута rem обязательны по правилам СТБ 34.101.23-cms. 
rem Третий атрибут описывает описывает хэш-значение сертификата TSA. 
rem Четвертый атрибут имеет мало смысла (время уже указано в штампе),
rem но подавить его через командную строку нельзя.
rem \warning В текущей редакции СТБ 34.101.ts требуется использовать не 
rem SigningCertificate, а SigningCertificateV2.
rem ===========================================================================

echo == Testing TSA Services ==================================================

set OPENSSL_CONF=openssl.cfg
md out 2> NUL
copy out\ca1\cert_ca1 + out\tsa\cert_tsa out\tsa\chain_tsa > NUL

echo -- 1 TSA Request1 --------------------------------------------------------

openssl ts -query -data tsa.cmd -bash256 -out out/tsa/req1.tsq -no_nonce 2> NUL

dumpasn1b -z -cdumpasn1by.cfg out/tsa/req1.tsq out/tsa/req1.txt 2> NUL

echo             stored in out/tsa/req1.tsq

echo -- 2 TSA Response1 -------------------------------------------------------

openssl ts -reply -queryfile out/tsa/req1.tsq ^
  -signer out/tsa/cert_tsa -passin pass:tsatsatsa -inkey out/tsa/privkey_tsa ^
  -out out/tsa/resp1.tsr -no_nonce 2> NUL

dumpasn1b -z -cdumpasn1by.cfg out/tsa/resp1.tsr out/tsa/resp1.txt 2> NUL

echo             stored in out/tsa/resp1.tsr

echo -- 3 TSA Verify1 ---------------------------------------------------------

openssl ts -verify -queryfile out/tsa/req1.tsq -in out/tsa/resp1.tsr ^
  -CAfile out/ca0/cert_ca0 -untrusted out/tsa/chain_tsa 2> NUL

echo -- 4 TSA Request2 --------------------------------------------------------

openssl ts -query -data tsa.cmd -bash512 -out out/tsa/req2.tsq -cert > NUL

dumpasn1b -z -cdumpasn1by.cfg out/tsa/req2.tsq out/tsa/req2.txt 2> NUL

echo             stored in out/tsa/req2.tsq

echo -- 5 TSA Response2 -------------------------------------------------------

openssl ts -reply -queryfile out/tsa/req2.tsq ^
  -signer out/tsa/cert_tsa -passin pass:tsatsatsa -inkey out/tsa/privkey_tsa ^
  -out out/tsa/resp2.tsr > NUL

dumpasn1b -z -cdumpasn1by.cfg out/tsa/resp2.tsr out/tsa/resp2.txt 2> NUL

echo             stored in out/tsa/resp2.tsr

echo -- 6 TSA Verify2 ---------------------------------------------------------

openssl ts -verify -data tsa.cmd -bash512 -in out/tsa/resp2.tsr ^
  -CAfile out/ca0/cert_ca0 -untrusted out/ca1/cert_ca1 2> NUL

openssl ts -verify -queryfile out/tsa/req2.tsq -in out/tsa/resp2.tsr ^
  -CAfile out/ca0/cert_ca0 -untrusted out/ca1/cert_ca1 2> NUL

echo == End ===================================================================
