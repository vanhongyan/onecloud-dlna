import subprocess
r = subprocess.run(['fbset','-fb','/dev/fb0','-xres','1920','-yres','1080','-depth','24'], capture_output=True, text=True)
print('fbset rc:', r.returncode)
r2 = subprocess.run(['python3','/home/src/fb_idle.py','ok'], capture_output=True, text=True)
print(r2.stdout.strip().splitlines()[-1] if r2.stdout else 'idle-fail')
# 关闭调试日志
s = open('/etc/systemd/system/gmediarender.service').read()
if 'GST_DEBUG=' in s:
    s = s.replace('Environment=GST_DEBUG=2\n','').replace('Environment=GST_DEBUG_NO_COLOR=1\n','')
    open('/etc/systemd/system/gmediarender.service','w').write(s)
    subprocess.run(['systemctl','daemon-reload'])
    subprocess.run(['systemctl','restart','gmediarender'])
    print('debug-off')
print('RESTORE-DONE')
