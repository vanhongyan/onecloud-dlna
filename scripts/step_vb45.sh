#!/bin/bash
echo '=== 本地验证 videobox 管道输出 ==='
gst-launch-1.0 -e videotestsrc pattern=smpte num-buffers=100 ! video/x-raw,width=1280,height=720,framerate=25/1 ! \
  videoscale add-borders=true ! video/x-raw,width=1280,height=720,pixel-aspect-ratio=1/1 ! \
  videobox fill=black left=-320 top=-180 right=-320 bottom=-180 ! fbdevsink &
GPID=$!
sleep 3
dd if=/dev/fb0 of=/home/src/fbtest/vb.raw bs=1M 2>/dev/null
kill $GPID 2>/dev/null || true
python3 -c "
from PIL import Image
raw=open('/home/src/fbtest/vb.raw','rb').read(1920*1080*3)
Image.frombytes('RGB',(1920,1080),raw).resize((480,270)).save('/home/src/fbtest/vb.png')
print('PNG-OK')
"
echo VB-DONE
