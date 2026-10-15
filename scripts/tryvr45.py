from PIL import Image
import subprocess

SRC = 'videotestsrc pattern=smpte num-buffers=75 ! video/x-raw,width=1280,height=720,format=I420,framerate=25/1 ! videoconvert ! '
variants = {
 'A_videorate_caps': SRC + 'videorate drop-only=true ! video/x-raw,framerate=30/1 ! videoscale method=nearest-neighbour ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! fakesink',
 'B_caps_then_rate': SRC + 'videoscale method=nearest-neighbour ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1,framerate=30/1 ! videorate drop-only=true ! fakesink',
 'C_rate_no_caps':   SRC + 'videorate drop-only=true ! videoscale method=nearest-neighbour ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1,framerate=30/1 ! fakesink',
}
for name, pipe in variants.items():
    r = subprocess.run(['timeout','8','gst-launch-1.0','-e'] + pipe.split(), capture_output=True, text=True)
    ok = 'ERROR' not in r.stderr and 'WARNING: erroneous' not in r.stderr
    tail = [l for l in r.stderr.splitlines() if 'could not' in l or 'erroneous' in l or 'EOS' in l or 'Execution ended' in l]
    print(name, 'OK' if ok else 'FAIL', '|', tail[-1][:120] if tail else '')
print('TRY-DONE')
