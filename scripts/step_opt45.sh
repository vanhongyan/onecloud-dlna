#!/bin/bash
set -e
python3 - <<'PYEOF'
p='/etc/systemd/system/gmediarender.service'
s=open(p).read()
old='videoscale add-borders=true ! video/x-raw,width=1280,height=720,pixel-aspect-ratio=1/1 ! videobox fill=black left=-320 top=-180 right=-320 bottom=-180 ! fbdevsink'
new='videoscale method=nearest add-borders=true ! video/x-raw,width=1280,height=720,pixel-aspect-ratio=1/1 ! videobox fill=black left=-320 top=-180 right=-320 bottom=-180 ! queue max-size-buffers=5 max-size-time=300000000 ! fbdevsink max-lateness=200000000'
assert old in s, 'pipe not found'
s=s.replace(old,new)
open(p,'w').write(s)
print('updated')
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 2
systemctl is-active gmediarender
tr '\0' '\n' < /proc/$(pidof gmediarender)/cmdline | grep -o 'method=nearest.*'
echo OPT-DONE
