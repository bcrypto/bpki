#!/bin/bash

bash gen_enroll1.sh $1
python3 post_enroll1.py $1
bash check_enroll1.sh $1
