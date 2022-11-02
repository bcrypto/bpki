#!/bin/bash

bash gen_tsa.sh
python3 post_tsa.py
bash check_tsa.sh