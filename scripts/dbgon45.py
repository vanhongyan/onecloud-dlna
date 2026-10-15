import subprocess
P = '/etc/systemd/system/gmediarender.service'
s = open(P).read()
if 'GST_DEBUG=' not in s:
    s = s.replace('[Service]\n', '[Service]\nEnvironment=GST_DEBUG=2\nEnvironment=GST_DEBUG_NO_COLOR=1\n')
    open(P, 'w').write(s)
subprocess.run(['systemctl','daemon-reload'])
subprocess.run(['systemctl','restart','gmediarender'])
import time; time.sleep(2)
print('service:', subprocess.run(['systemctl','is-active','gmediarender'],capture_output=True,text=True).stdout.strip())
print('DBG-ON')
