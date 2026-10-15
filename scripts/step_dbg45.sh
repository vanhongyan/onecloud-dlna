#!/bin/bash
set -e
python3 - <<'PYEOF'
p='/etc/systemd/system/gmediarender.service'
s=open(p).read()
if 'GST_DEBUG=' not in s:
    s=s.replace('[Service]\n','[Service]\nEnvironment=GST_DEBUG=2\nEnvironment=GST_DEBUG_NO_COLOR=1\n')
open(p,'w').write(s)
print('debug-on')
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 2
systemctl is-active gmediarender
echo DBG-ON
