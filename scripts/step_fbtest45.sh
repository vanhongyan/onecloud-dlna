#!/bin/bash
set -e
D=/home/src/fbtest
mkdir -p $D
# 1) 16:9 源(640x360) 过投屏同款管道 5 秒
gst-launch-1.0 -e videotestsrc pattern=smpte num-buffers=125 ! video/x-raw,width=640,height=360,framerate=25/1 ! \
  videoscale add-borders=true ! video/x-raw,width=1920,height=1080 ! fbdevsink &
GPID=$!
sleep 6; kill $GPID 2>/dev/null || true
cat /dev/fb0 > $D/fb_169.raw 2>/dev/null || dd if=/dev/fb0 of=$D/fb_169.raw bs=1M
# 2) 9:16 源(360x640)
gst-launch-1.0 -e videotestsrc pattern=smpte num-buffers=125 ! video/x-raw,width=360,height=640,framerate=25/1 ! \
  videoscale add-borders=true ! video/x-raw,width=1920,height=1080 ! fbdevsink &
GPID=$!
sleep 6; kill $GPID 2>/dev/null || true
dd if=/dev/fb0 of=$D/fb_916.raw bs=1M
# 3) 转成 PNG
python3 - <<'EOF'
from PIL import Image
W,H=1920,1080
for name in ['fb_169','fb_916']:
    raw=open(f'/home/src/fbtest/{name}.raw','rb').read(W*H*3)
    img=Image.frombytes('RGB',(W,H),raw[:W*H*3])
    img=img.resize((480,270))
    img.save(f'/home/src/fbtest/{name}.png')
print('PNG-DONE')
EOF
# 4) CPU 参考管道性能
echo TEST-DONE
