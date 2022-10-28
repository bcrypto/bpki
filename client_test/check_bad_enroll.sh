export OPENSSL_CONF=openssl.cfg

echo "--1  Decode Signed(Response)"
bash dump.sh answers/bpki_resp.der
# cat answers/bpki_resp.der.txt

echo "--2  Verify Signed(Response)"
openssl cms -verify -in answers/bpki_resp.der -inform der \
  -CAfile out/ca1/chain -out answers/bpkiresp.der -outform der -purpose any

echo "--3  Decode Response"
bash dump.sh answers/bpkiresp.der
cat answers/bpkiresp.der.txt
