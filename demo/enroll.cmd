@echo off
rem ===========================================================================
rem \brief Процесc Enroll
rem \project bpki/demo
rem \remark Выпускаются сертификаты np, lr, fnp, acd
rem ===========================================================================

set OPENSSL_CONF=openssl.cfg

echo == Enroll1(fnp)... =======================================================

call enroll1 np 730

echo == Enroll2(lr)... ========================================================

call enroll2 fnp 730

echo == Enroll3(np)... ========================================================

call enroll3 lr 730

echo == Enroll4(acd)... =======================================================

call enroll4 acd 1095

echo == End ===================================================================
