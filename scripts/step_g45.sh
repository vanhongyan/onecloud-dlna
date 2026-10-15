#!/bin/bash
D=/home/src/fbtest
for i in 1 2; do dd if=/dev/fb0 of=$D/g_$i.raw bs=1M 2>/dev/null; sleep 2; done
python3 -c "
from PIL import Image
for i in [1,2]:
    raw=open('/home/src/fbtest/g_%d.raw'%i,'rb').read(1920*1080*3)
    Image.frombytes('RGB',(1920,1080),raw).resize((480,270)).save('/home/src/fbtest/g_%d.png'%i)
print('OK')
"
echo G-DONE
