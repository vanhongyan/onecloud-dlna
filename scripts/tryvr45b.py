import subprocess

def run(name, pipe):
    r = subprocess.run(['timeout','15','gst-launch-1.0','-e'] + pipe.split(), capture_output=True, text=True)
    bad = [l for l in r.stderr.splitlines() if 'ERROR' in l or 'could not' in l]
    print(name, 'RC', r.returncode, '|', (bad[-1][:90] if bad else 'clean'))

base = 'uridecodebin uri=file:///tmp/t.mkv ! '
run('plain_vr_30', base + 'videoscale method=nearest-neighbour add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! videorate ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1,framerate=30/1 ! queue max-size-buffers=5 max-size-time=300000000 ! fbdevsink max-lateness=200000000')
