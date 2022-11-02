#!/bin/bash

bash tsa.sh
python3 post_tsa.py
bash check_tsa.sh