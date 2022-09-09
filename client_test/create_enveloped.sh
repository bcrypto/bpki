export OPENSSL_CONF=openssl.cfg

openssl genpkey -paramfile out/params256 -out out/fnp/privkey_pre -pass pass:fnpfnpfnp

openssl pkcs8 -in out/fnp/privkey_pre -passin pass:fnpfnpfnp -topk8 \
	-v2 belt-kwp256 -v2prf belt-hmac -iter 10000 \
 	-passout pass:fnpfnpfnp -out out/fnp/privkey 

openssl req -new -utf8 -nameopt multiline,utf8 -newkey bign:out/params256 \
  -config ./cfg/fnp.cfg -keyout out/fnp/privkey -reqexts reqexts \
  -out out/fnp/csr -passout pass:fnpfnpfnp -batch

openssl cms -sign -signer out/opra/cert \
  -inkey out/opra/privkey -passin pass:opraopraopra \
  -in out/fnp/csr -binary -econtent_type bpki-ct-enroll1-req \
  -out out/fnp/signed_csr -outform pem -nodetach -nosmimecap

openssl cms -encrypt -binary -in out/fnp/signed_csr -inform der \
  -recip out/ca1/cert -belt-cfb256 \
  -out out/fnp/enveloped_signed_csr -outform pem
