#!/bin/bash

bash gen_setpwd.sh $1 1234567
python3 post_setpwd.py $1
bash check_setpwd.sh $1