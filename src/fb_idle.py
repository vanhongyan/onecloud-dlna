#!/usr/bin/env python3
"""Draw standby screen (or solid color) directly to /dev/fb0.

Usage:
  fb_idle.py            -> draw standby screen
  fb_idle.py black      -> fill black
"""
import sys, struct, fcntl, termios
from PIL import Image, ImageDraw, ImageFont

FB = "/dev/fb0"
FBIOGET_VSCREENINFO = 0x4600
FBIOGET_FSCREENINFO = 0x4602

def fb_info():
    with open(FB, "rb") as f:
        vi = fcntl.ioctl(f, FBIOGET_VSCREENINFO, b"\0" * 160)
        xres, yres, xres_v, yres_v, xoff, yoff = struct.unpack("6I", vi[:24])
        bpp = struct.unpack("I", vi[24:28])[0]
        fi = fcntl.ioctl(f, FBIOGET_FSCREENINFO, b"\0" * 256)
        line_len = struct.unpack("I", fi[44:48])[0]
    return xres, yres, xres_v, bpp, line_len

def draw(xres, yres, xres_v, bpp, line_len, state="ok"):
    img = Image.new("RGB", (xres, yres), (0, 0, 0))
    d = ImageDraw.Draw(img)
    try:
        f1 = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 56)
        f2 = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 30)
    except Exception:
        f1 = f2 = ImageFont.load_default()
    if state == "starting":
        t1 = "OneCloud-TV"
        t2 = "DLNA renderer starting..."
    else:
        t1 = "OneCloud-TV"
        t2 = "DLNA standby - cast from your phone"
    w1 = d.textlength(t1, font=f1); w2 = d.textlength(t2, font=f2)
    cx = xres // 2
    d.text((cx - w1/2, yres//2 - 70), t1, font=f1, fill=(240, 240, 240))
    d.text((cx - w2/2, yres//2 + 10), t2, font=f2, fill=(150, 150, 150))
    if state == "starting":
        # framed = still starting; success frame has no border
        d.rectangle([cx - 280, yres//2 - 140, cx + 280, yres//2 + 100],
                    outline=(180, 180, 180), width=6)
    return img, "RGB"

def write(img, xres, yres, xres_v, bpp, line_len):
    with open(FB, "wb") as f:
        if bpp == 32:
            bgra = Image.merge("RGBA", (img.split()[2], img.split()[1], img.split()[0],
                                        Image.new("L", img.size, 255)))
            raw = bgra.tobytes("raw", "BGRA")
            stride = line_len
            if stride == xres_v * 4:
                f.write(raw[: stride * yres])
            else:
                row = raw[: xres_v * 4]
                pad = b"\0" * (stride - xres_v * 4)
                f.write(b"".join(row[y * xres_v * 4:(y + 1) * xres_v * 4] + pad for y in range(yres)))
        elif bpp == 24:
            rgb = img.convert("RGB").tobytes()
            stride = line_len
            rowbytes = xres * 3
            for y in range(yres):
                f.write(rgb[y * rowbytes:(y + 1) * rowbytes])
                f.write(b"\0" * (stride - rowbytes))

if __name__ == "__main__":
    state = sys.argv[1] if len(sys.argv) > 1 else "ok"
    xres, yres, xres_v, bpp, line_len = fb_info()
    img, _ = draw(xres, yres, xres_v, bpp, line_len, state)
    write(img, xres, yres, xres_v, bpp, line_len)
    print("IDLE_DRAWN", state, xres, yres, bpp)
