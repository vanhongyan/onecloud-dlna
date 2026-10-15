#!/bin/bash
D=/home/src/fbtest
for i in 1 2 3; do
  dd if=/dev/fb0 of=$D/live_$i.raw bs=1M 2>/dev/null
  sleep 1
done
python3 - <<'EOF'
from PIL import Image
W,H=1920,1080
for i in [1,2,3]:
    try:
        raw=open(f'/home/src/fbtest/live_{i}.raw','rb').read(W*H*3)
        Image.frombytes('RGB',(W,H),raw).resize((480,270)).save(f'/home/src/fbtest/live_{i}.png')
    except Exception as e: print(e)
print('PNG-DONE')
EOF
echo LIVE-DONE
