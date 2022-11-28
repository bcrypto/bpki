import bpkipy

dvcs_data = '1q2w3e'.encode('utf-8')
print(dvcs_data)
dvcs_req = bpkipy.dvcs_request(dvcs_data)
print(dvcs_req)
