#!/bin/bash

# answers/dumpasn1b -z -canswers/dumpasn1by.cfg answers/bpki_resp.der answers/bpki_resp.der.txt
answers/dumpasn1b -z -canswers/dumpasn1by.cfg "$1" "$1.txt"