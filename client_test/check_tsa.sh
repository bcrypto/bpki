#@echo off
#rem ===========================================================================
#rem \brief Запрос и ответ TSA = TimeStamp Authority
#rem \project bpki/demo
#rem \created 2018.01.10
#rem \version 2018.01.23
#rem \pre Выполнен скрипт setup.cmd.
#rem \remark ТSA = СШВ = Служба штампов времени
#rem \remark Выпускаются две пары "запрос - ответ": лаконичная и подробная.
#rem В лаконичной паре заблокированы нонсы, сертификат TSA не включается в 
#rem ответ. В подробной паре все наоборот.
#rem \remark Ответ TSA представляет собой контейнер с двумя полями: 
#rem   - cтатус обработки,
#rem   - штамп времени -- контейнер типа SignedData. 
#rem Штамп времени как SignedData включает 4 подписанных атрибута: contentType, 
#rem MessageDigest, SigningCertificate, SigningTime. 
#rem Первые два атрибута rem обязательны по правилам СТБ 34.101.23-cms. 
#rem Третий атрибут описывает описывает хэш-значение сертификата TSA. 
#rem Четвертый атрибут имеет мало смысла (время уже указано в штампе),
#rem но подавить его через командную строку нельзя.
#rem \warning В текущей редакции СТБ 34.101.ts требуется использовать не 
#rem SigningCertificate, а SigningCertificateV2.
#rem ===========================================================================

echo == Testing TSA Services ==================================================

export OPENSSL_CONF=openssl.cfg
mkdir out/tsa 2> /dev/null
cat out/ca1/cert out/tsa/cert > out/tsa/chain

#echo -- 1 TSA Request1 ---------------------

#openssl ts -query -data tsa.sh -bash256 -out out/tsa/req1.tsq -no_nonce

#dumpasn1b -z -cdumpasn1by.cfg out/tsa/req1.tsq out/tsa/req1.txt 2> /dev/null

#echo stored in out/tsa/req1.tsq

#echo -- 2 TSA Response1 --------------------

#openssl ts -reply -queryfile out/tsa/req1.tsq \
#  -signer out/tsa/cert -passin pass:tsatsatsa -inkey out/tsa/privkey \
#  -out out/tsa/resp1.tsr -no_nonce 2> /dev/null

#dumpasn1b -z -cdumpasn1by.cfg out/tsa/resp1.tsr out/tsa/resp1.txt 2> /dev/null

#echo stored in out/tsa/resp1.tsr

echo -- 3 TSA Verify1 ----------------------

openssl ts -verify -queryfile out/tsa/req1.tsq -in answers/tsa/resp1.tsr \
  -CAfile out/ca0/cert -untrusted out/tsa/chain

#echo -- 4 TSA Request2 ---------------------

#openssl ts -query -data tsa.sh -bash512 -out out/tsa/req2.tsq -cert > /dev/null

#dumpasn1b -z -cdumpasn1by.cfg out/tsa/req2.tsq out/tsa/req2.txt 2> /dev/null

#echo stored in out/tsa/req2.tsq

#echo -- 5 TSA Response2 --------------------

#openssl ts -reply -queryfile out/tsa/req2.tsq \
#  -signer out/tsa/cert -passin pass:tsatsatsa -inkey out/tsa/privkey \
#  -out out/tsa/resp2.tsr 2> /dev/null

#dumpasn1b -z -cdumpasn1by.cfg out/tsa/resp2.tsr out/tsa/resp2.txt 2> /dev/null

#echo stored in out/tsa/resp2.tsr

echo -- 6 TSA Verify2 ----------------------

openssl ts -verify -data tsa.sh -bash512 -in answers/tsa/resp2.tsr \
  -CAfile out/ca0/cert -untrusted out/ca1/cert #2> /dev/null

openssl ts -verify -queryfile out/tsa/req2.tsq -in answers/tsa/resp2.tsr \
  -CAfile out/ca0/cert -untrusted out/ca1/cert #2> /dev/null

#echo == End ===================================================================
