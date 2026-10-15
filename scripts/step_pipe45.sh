#!/bin/bash
set -e
python3 - <<'PYEOF'
p='/etc/systemd/system/gmediarender.service'
s=open(p).read()
old='videoscale add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! fbdevsink'
new='videoscale add-borders=true ! video/x-raw,width=1280,height=720,pixel-aspect-ratio=1/1 ! videobox fill=black left=-320 top=-180 right=-320 bottom=-180 ! fbdevsink'
assert old in s, 'old pipe not found'
s=s.replace(old,new)
open(p,'w').write(s)
print('pipe-updated')
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 2
systemctl is-active gmediarender
grep -o 'videopipe=.*' /etc/systemd/system/gmediarender.service | head -1
tr '\0' '\n' < /proc/$(pidof gmediarender)/cmdline | grep -o 'videobox.*' | head -1
echo PIPE-DONE
