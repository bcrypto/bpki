import bpkipy

print(bpkipy.hello())
request_id = bytes.fromhex("0101010101010101010101010101010101010101010101010101010101010101")
nonce = bytes.fromhex("0808080808080808")
print(len(request_id))
errors = ["Error1", "Error2"]
print(bpkipy.create_response(status=3, req_id=request_id, nonce=nonce, error_list=errors, failure=4))

help(bpkipy)


