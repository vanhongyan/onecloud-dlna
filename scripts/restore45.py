from PIL import Image
import subprocess, time

# 恢复 fb 模式
r = subprocess.run(['fbset','-fb','/dev/fb0','-xres','1920','-yres','1080','-vxres','1920','-vyres','1080','-depth','24'],capture_output=True,text=True)
print('fbset rc:', r.returncode, r.stderr[:200])

print(open('/sys/class/graphics/fb0/virtual_size').read().strip())
r2 = subprocess.run(['python3','/home/src/fb_idle.py','ok'],capture_output=True,text=True)
print(r2.stdout.strip().splitlines()[-1] if r2.stdout else r2.stderr[:200])

# 验证：测试图应满屏
p = subprocess.Popen(['gst-launch-1.0','-e'] + ('videotestsrc pattern=smpte num-buffers=150 ! video/x-raw,width=640,height=360,framerate=25/1 ! videoscale method=nearest-neighbour add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! fbdevsink').split())
time.sleep(3)
with open('/dev/fb0','rb') as f:
    raw = f.read(1920*1080*3)
Image.frombytes('RGB',(1920,1080),raw).resize((480,270)).save('/home/src/fbtest/t_restore.png')
p.terminate(); p.wait()
print('RESTORE-DONE')
