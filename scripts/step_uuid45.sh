#!/bin/bash
set -e
NEWUUID=$(cat /proc/sys/kernel/random/uuid)
echo "new uuid: $NEWUUID"
python3 - "$NEWUUID" <<'PYEOF'
import sys
u=sys.argv[1]
p='/etc/systemd/system/gmediarender.service'
s=open(p).read()
s=s.replace('<REPLACE-WITH-YOUR-UUID>',u)
open(p,'w').write(s)
print('uuid-replaced')
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 2
systemctl is-active gmediarender
tr '\0' ' ' < /proc/$(pidof gmediarender)/cmdline | grep -o '\-u [0-9a-f-]*'
echo U-DONE
