import os
import sys
import bpkipy

entity = sys.argv[1]

if not os.path.exists(f"out/{entity}"):
    os.mkdir(f"out/{entity}")

rev_req = bpkipy.create_revoke(
    cert_file=f"answers/{entity}/cert.der",
    password="12k",
    reason=3
)
with open(f"out/{entity}/revoke_req.der", "wb") as f:
    f.write(rev_req)
print(f" stored in out/{entity}/revoke_req.der")
