import bpkipy

dvcs_req = bytes.fromhex('301030060201010a01020406317132773365')
print(dvcs_req)
print(bpkipy.dvcs_extract_data(dvcs_req))
