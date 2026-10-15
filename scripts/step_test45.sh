#!/bin/bash
# 验证竖屏 letterbox 是否生效 + gm-idle 状态
set -x
echo "==== gm-idle log ===="
journalctl -u gm-idle --no-pager -n 15
echo "==== 生成竖屏测试视频(720x1280) ===="
rm -f /tmp/test_portrait.mp4
timeout 30 gst-launch-1.0 -e videotestsrc num-buffers=150 pattern=snow ! video/x-raw,width=720,height=1280,framerate=25/1 ! x264enc tune=zerolatency ! mp4mux ! filesink location=/tmp/test_portrait.mp4 2>&1 | tail -2
ls -la /tmp/test_portrait.mp4
echo "==== 画待机画面做基线 ===="
python3 /home/src/fb_idle.py ok
sleep 1
echo "==== 用与 gmediarender 相同管道播放 6 秒 ===="
timeout 8 gst-launch-1.0 filesrc location=/tmp/test_portrait.mp4 ! qtdemux ! decodebin ! videoscale add-borders=true ! video/x-raw,width=1280,height=720 ! fbdevsink 2>&1 | tail -3
echo "==== 抓取fb0分析黑边 ===="
python3 - <<'EOF'
# fb0: 1280x720 24bpp stride 3840
f = open('/dev/fb0','rb')
stride = 3840
row = 360  # 中间行
f.seek(row*stride)
data = f.read(stride)
def lum(b): return (b[0]+b[1]+b[2])/3 if isinstance(b,(bytes,bytearray)) else None
# 检查左边缘/右边缘/中心亮度
def avg(x0,x1):
    seg = data[x0*3:x1*3]
    return sum(seg)/len(seg)
print("left  0-100 avg:", round(avg(0,100),1))
print("mid   590-690 avg:", round(avg(590,690),1))
print("right 1180-1280 avg:", round(avg(1180,1280),1))
EOF
echo TEST-DONE
