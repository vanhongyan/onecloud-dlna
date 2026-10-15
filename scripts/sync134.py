import subprocess, shutil

P = '/etc/systemd/system/gmediarender.service'
shutil.copy(P, P + '.bak')
s = open(P).read()
old = '--gstout-videopipe="videoflip method=automatic ! videoscale ! video/x-raw,width=1280,height=720 ! fbdevsink"'
new = '--gstout-videopipe="videoflip method=automatic ! videoscale method=nearest-neighbour add-borders=true ! video/x-raw,width=1280,height=720,pixel-aspect-ratio=1/1 ! queue max-size-buffers=5 max-size-time=300000000 ! fbdevsink max-lateness=200000000"'
assert old in s, 'old pipe not found:\n' + s
s = s.replace(old, new)
open(P, 'w').write(s)
subprocess.run(['systemctl', 'daemon-reload'])
r = subprocess.run(['systemctl', 'restart', 'gmediarender'])
import time; time.sleep(2)
st = subprocess.run(['systemctl', 'is-active', 'gmediarender'], capture_output=True, text=True)
print('service:', st.stdout.strip())
cmd = open('/proc/%d/cmdline' % int(subprocess.run(['pidof','gmediarender'],capture_output=True,text=True).stdout.split()[0]),'rb').read().decode().replace('\0',' ')
i = cmd.find('videopipe=')
print(cmd[i:i+180])
print('SYNC-DONE')
