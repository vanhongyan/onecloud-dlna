from PIL import Image
import subprocess, time, os

def dump(name):
    with open('/dev/fb0','rb') as f:
        raw = f.read(1920*1080*3)
    Image.frombytes('RGB',(1920,1080),raw).resize((480,270)).save('/home/src/fbtest/%s.png'%name)

pipe_full = ('videotestsrc pattern=smpte num-buffers=150 ! video/x-raw,width=640,height=360,framerate=25/1 ! '
 'videoscale method=nearest-neighbour add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! '
 'queue max-size-buffers=5 max-size-time=300000000 ! fbdevsink max-lateness=200000000')
pipe_simple = ('videotestsrc pattern=smpte num-buffers=150 ! video/x-raw,width=640,height=360,framerate=25/1 ! '
 'videoscale method=nearest-neighbour add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! '
 'fbdevsink')

for name, pipe in [('t_queue', pipe_full), ('t_simple', pipe_simple)]:
    p = subprocess.Popen(['gst-launch-1.0','-e'] + pipe.split())
    time.sleep(3)
    dump(name)
    p.terminate(); p.wait()
print('TEST-DONE')
