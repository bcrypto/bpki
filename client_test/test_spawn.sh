#!/bin/bash

bash gen_reenroll.sh $1
python3 post_enroll.py reenroll spawn
bash check_reenroll.sh spawn