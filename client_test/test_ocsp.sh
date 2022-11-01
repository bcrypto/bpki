#!/bin/bash

bash gen_ocsp.sh $1
python3 post_ocsp.py $1
bash check_ocsp.sh $1