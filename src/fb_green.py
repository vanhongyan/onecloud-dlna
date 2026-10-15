#!/usr/bin/env python3
import struct, fcntl
f = open("/dev/fb0", "r+b")
vi = fcntl.ioctl(f, 0x4600, b"\0" * 160)
xres, yres = struct.unpack("2I", vi[:8])
bpp = struct.unpack("I", vi[24:28])[0]
fi = fcntl.ioctl(f, 0x4602, b"\0" * 256)
stride = struct.unpack("I", fi[44:48])[0]
print("xres", xres, "yres", yres, "bpp", bpp, "stride", stride)
px = 3 if bpp == 24 else 4
row = bytearray()
for x in range(xres):
    row += b"\x00\xff\x00" + (b"\x00" if px == 4 else b"")
row += b"\0" * (stride - len(row))
f.seek(0)
for y in range(yres):
    f.write(row)
f.flush()
print("GREEN_DONE")
