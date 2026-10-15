#!/bin/bash
set -e
python3 - <<'PYEOF'
p='/etc/systemd/system/gmediarender.service'
s=open(p).read()
s=s.replace('--gstout-buffer-duration=15 ','')
open(p,'w').write(s)
print('buffer-param-removed:', '--gstout-buffer-duration' not in s)
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 2
systemctl is-active gmediarender
tr '\0' '\n' < /proc/$(pidof gmediarender)/cmdline | grep -c buffer-duration || echo 'buffer-duration GONE OK'
echo REV-DONE
