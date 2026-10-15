#!/bin/bash
set -e
D=/home/src/fbtest
# 9:16 源 + 强制 PAR 1/1
gst-launch-1.0 -e videotestsrc pattern=smpte num-buffers=125 ! video/x-raw,width=360,height=640,framerate=25/1 ! \
  videoscale add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! fbdevsink &
GPID=$!
sleep 3
dd if=/dev/fb0 of=$D/fb_fix916.raw bs=1M
wait $GPID 2>/dev/null || true
# 16:9 源 + 强制 PAR
gst-launch-1.0 -e videotestsrc pattern=smpte num-buffers=125 ! video/x-raw,width=640,height=360,framerate=25/1 ! \
  videoscale add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! fbdevsink &
GPID=$!
sleep 3
dd if=/dev/fb0 of=$D/fb_fix169.raw bs=1M
wait $GPID 2>/dev/null || true
python3 - <<'EOF'
from PIL import Image
W,H=1920,1080
for name in ['fb_fix916','fb_fix169']:
    raw=open(f'/home/src/fbtest/{name}.raw','rb').read(W*H*3)
    Image.frombytes('RGB',(W,H),raw).resize((480,270)).save(f'/home/src/fbtest/{name}.png')
print('PNG-DONE')
EOF
echo FIXTEST-DONE
