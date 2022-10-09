echo "-- 1 dump Signed(Revoke($1))"

bash dump.sh out/$1/revoke.csr
cat out/$1/revoke.csr.txt

bash dump.sh out/$1/revoke.der
cat out/$1/revoke.der.txt
