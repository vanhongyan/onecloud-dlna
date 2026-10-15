import subprocess
P = '/etc/systemd/system/gmediarender.service'
s = open(P).read()
old = 'video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1'
new = 'video/x-raw,width=1280,height=720,pixel-aspect-ratio=1/1'
assert old in s, 'caps not found'
s = s.replace(old, new)
open(P, 'w').write(s)
subprocess.run(['systemctl','daemon-reload'])
subprocess.run(['systemctl','restart','gmediarender'])
import time; time.sleep(2)
print('service:', subprocess.run(['systemctl','is-active','gmediarender'],capture_output=True,text=True).stdout.strip())
cmd = open('/proc/%d/cmdline' % int(subprocess.run(['pidof','gmediarender'],capture_output=True,text=True).stdout.split()[0]),'rb').read().decode().replace('\0',' ')
i = cmd.find('videopipe=')
print(cmd[i:i+170])
print('PIPE-DONE')
