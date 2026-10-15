#!/bin/bash
set -e
cp /home/src/fb_idle.py /home/src/fb_idle.py.bak
python3 - <<'PYEOF'
p='/home/src/fb_idle.py'
s=open(p).read()
old='    return xres, yres, xres_v, bpp, line_len'
new='    return xres_v, yres_v, xres_v, bpp, line_len'
assert old in s
s=s.replace(old,new)
open(p,'w').write(s)
print('patched')
PYEOF
python3 /home/src/fb_idle.py ok 2>&1 | tail -1
sleep 1
dd if=/dev/fb0 of=/home/src/fbtest/r2.raw bs=1M 2>/dev/null
python3 -c "
from PIL import Image
raw=open('/home/src/fbtest/r2.raw','rb').read(1920*1080*3)
Image.frombytes('RGB',(1920,1080),raw).resize((480,270)).save('/home/src/fbtest/r2.png')
print('PNG-OK')
"
echo PATCH-DONE
