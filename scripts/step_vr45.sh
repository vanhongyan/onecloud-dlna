#!/bin/bash
set -e
echo '=== 播放中 ALSA 实际参数(顺带核查时钟) ==='
cat /proc/asound/card0/pcm0p/sub0/hw_params 2>/dev/null | grep -E 'format|rate' || echo none
python3 - <<'PYEOF'
p='/etc/systemd/system/gmediarender.service'
s=open(p).read()
old='videoscale method=nearest-neighbour add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1'
new='videorate drop-only=true ! video/x-raw,framerate=30/1 ! videoscale method=nearest-neighbour add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1'
assert old in s, 'pipe not found'
s=s.replace(old,new)
open(p,'w').write(s)
print('videorate-added')
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 2
systemctl is-active gmediarender
tr '\0' ' ' < /proc/$(pidof gmediarender)/cmdline | grep -o 'videorate[^!]*' | head -c 80
echo
echo VR-DONE
