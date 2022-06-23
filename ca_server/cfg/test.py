import re

with open("fnp.cfg", 'r') as f:
    data = f.read()

sn = re.search(r'serialNumber\s=.*(\n)?', data).group(0)
sn = sn.split('=')[1].strip('\n \t')
print(sn)
