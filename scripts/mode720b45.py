import subprocess
from PIL import Image, ImageDraw

# 撤 videorate：恢复之前可用的优化管道
s = open('/etc/systemd/system/gmediarender.service').read()
old = 'videorate drop-only=true ! video/x-raw,framerate=30/1 ! videoscale'
if old in s:
    s = s.replace(old, 'videoscale')
    open('/etc/systemd/system/gmediarender.service','w').write(s)
    subprocess.run(['systemctl','daemon-reload'])
    subprocess.run(['systemctl','restart','gmediarender'])
    print('videorate-removed')

# fb 全参数降到 1280x720（含虚拟尺寸）
r = subprocess.run(['fbset','-fb','/dev/fb0','-xres','1280','-yres','720','-vxres','1280','-vyres','720','-depth','24'], capture_output=True, text=True)
print('fbset rc:', r.returncode, r.stderr[:100])
print('virtual:', open('/sys/class/graphics/fb0/virtual_size').read().strip())
print('stride:', open('/sys/class/graphics/fb0/stride').read().strip())

# 画全屏标记（按新 1280x720 尺寸）供用户目视确认是否满屏
img = Image.new('RGB',(1280,720),(30,30,30))
d = ImageDraw.Draw(img)
d.rectangle([0,0,1279,719], outline=(255,255,0), width=8)      # 黄框(电视上看是蓝框)
d.rectangle([560,280,720,440], fill=(255,255,255))
with open('/dev/fb0','wb') as f:
    f.write(img.convert('RGB').tobytes())
print('MARK-DONE')
