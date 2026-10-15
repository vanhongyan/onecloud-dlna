#!/bin/bash
echo '=== cmdline 确认 ==='
cat /proc/cmdline
echo '=== fb 尺寸 ==='
echo -n 'virtual_size: '; cat /sys/class/graphics/fb0/virtual_size
echo -n 'stride: '; cat /sys/class/graphics/fb0/stride
python3 -c "
import fcntl, struct
f=open('/dev/fb0','rb')
vi=fcntl.ioctl(f,0x4600,b'\0'*160)
x,y,xv,yv=struct.unpack('4I',vi[:16])
print('xres,yres,vxres,vyres =',x,y,xv,yv)
"
echo '=== HDMI 模式 ==='
for p in /sys/class/drm/card*-HDMI-A-1; do
  [ -d "$p" ] && echo "$p enabled=$(cat $p/enabled 2>/dev/null) status=$(cat $p/status 2>/dev/null) mode=$(cat $p/modes 2>/dev/null | head -1)"
done
echo '=== gmediarender 自动起来了? ==='
systemctl is-active gmediarender
systemctl is-active gm-idle
echo '=== 声卡 ==='
cat /proc/asound/cards 2>/dev/null | head -3
echo BOOT-CHECK-DONE
