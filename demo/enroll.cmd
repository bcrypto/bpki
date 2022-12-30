@echo off
rem ===========================================================================
rem \brief Процесc Enroll
rem \project bpki/demo
rem \created 2018.01.10
rem \version 2022.12.30
rem \pre Выполнен скрипт setup.cmd.
rem \remark Выпускаются сертификаты np, lr, fnp, acd
rem ===========================================================================

set OPENSSL_CONF=openssl.cfg

echo == Enroll1(fnp)... =======================================================

call enroll1 fnp 730
call enroll1 lr 730

echo == Enroll2(lr)... ========================================================

call enroll2 np 730

echo == Enroll3(acd)... =======================================================

call enroll3 acd 1095

echo == Issue CRL (ca1) =======================================================

openssl ca -gencrl -name ca1 -key ca1ca1ca1 -crlhours 1 ^
  -crlexts crlexts -out out/ca1/crl3 -batch 2> nul

call decode out/ca1/crl3 > nul

echo == End ===================================================================
