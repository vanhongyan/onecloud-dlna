import subprocess

P = '/boot/armbianEnv.txt'
s = open(P).read()
# 备份
open('/boot/armbianEnv.txt.bak', 'w').write(s)
lines = s.splitlines()
out = []
for l in lines:
    if l.strip().startswith('# extraargs=') or l.strip().startswith('extraargs='):
        out.append('extraargs="video=HDMI-A-1:1280x720@60D"')
    else:
        out.append(l)
if not any(l.startswith('extraargs=') for l in out):
    out.append('extraargs="video=HDMI-A-1:1280x720@60D"')
open(P, 'w').write('\n'.join(out) + '\n')
print(open(P).read())
print('EDIT-DONE')
