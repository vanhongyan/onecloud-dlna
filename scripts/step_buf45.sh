#!/bin/bash
set -e
python3 - <<'PYEOF'
p='/etc/systemd/system/gmediarender.service'
s=open(p).read()
if '--gstout-buffer-duration' not in s:
    s=s.replace('--gstout-audiosink=alsasink','--gstout-buffer-duration=15 --gstout-audiosink=alsasink')
open(p,'w').write(s)
print(open(p).read().split('ExecStart=')[1].split('\n')[0][:160])
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 3
systemctl is-active gmediarender
journalctl -u gmediarender -n 60 --no-pager | grep -i 'buffer duration' | tail -1
echo BUF-DONE
