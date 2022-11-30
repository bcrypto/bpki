#!/bin/bash

export OPENSSL_CONF=openssl.cfg

bash gen_revoke.sh $1
python3 post_revoke.py $1 1
bash check_revoke.sh $1 1
