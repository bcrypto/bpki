import bpkipy

errors = ["Error1", "Error2"]
print(bpkipy.dvcs_error_notice(status=3, error_list=errors, failure=4))
