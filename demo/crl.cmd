echo == Initializing PKI ======================================================

set OPENSSL_CONF=openssl.cfg
md out 2> nul

for /f "usebackq tokens=1,2 delims==" %%i in (
  `wmic os get LocalDateTime /value 2^>nul`
) do if '.%%i.'=='.LocalDateTime.' set ldt=%%j

set ldt=%ldt:~0,14%Z

echo GeneralizedTime = %ldt%

echo == 1 Issue CRL (ca0 and ca1) ====================================

openssl ca -gencrl -name ca0 -key ca0ca0ca0 -crlhours 1 ^
  -crlexts crlexts -out out/ca0/crl3 -batch 2> nul

call decode out/ca0/crl3 > nul

openssl ca -gencrl -name ca1 -key ca1ca1ca1 -crlhours 1 ^
  -crlexts crlexts -out out/ca1/crl3 -batch 2> nul

call decode out/ca1/crl3 > nul