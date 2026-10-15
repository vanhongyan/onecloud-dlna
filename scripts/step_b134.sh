#!/bin/bash
echo '=== 134 fb 几何 ==='
echo -n 'virtual_size: '; cat /sys/class/graphics/fb0/virtual_size
echo -n 'stride: '; cat /sys/class/graphics/fb0/stride
echo -n 'bpp: '; cat /sys/class/graphics/fb0/bits_per_pixel
python3 -c "
import fcntl, struct
f=open('/dev/fb0','rb')
vi=fcntl.ioctl(f, 0x4600, b'\0'*160)
x,y,xv,yv=struct.unpack('4I', vi[:16])
print('xres,yres,vxres,vyres =', x,y,xv,yv)
"
echo '=== 134 管道 ==='
tr '\0' ' ' < /proc/$(pidof gmediarender)/cmdline | grep -o 'videopipe=.*' | head -c 160
echo
echo '=== 134 是否有丢帧记录(需要debug才会记) ==='
journalctl -u gmediarender -n 50 --no-pager 2>/dev/null | grep -c 'QoS' || true
echo B134-DONE
