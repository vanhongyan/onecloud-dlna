#!/bin/bash
python3 - <<'PYEOF'
p='/etc/systemd/system/gmediarender.service'
s=open(p).read()
s=s.replace('Environment=GST_DEBUG=2\n','').replace('Environment=GST_DEBUG_NO_COLOR=1\n','')
open(p,'w').write(s)
print('debug-removed:', 'GST_DEBUG' not in s)
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 2
python3 /home/src/fb_idle.py ok 2>&1 | tail -1
systemctl is-active gmediarender
echo CLEAN-DONE
