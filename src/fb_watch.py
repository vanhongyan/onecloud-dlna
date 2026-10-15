#!/usr/bin/env python3
"""Watch gmediarender journal; draw standby screen when playback stops."""
import subprocess, time, sys
sys.path.insert(0, "/home/src")
import fb_idle

DEBOUNCE = 10.0
last = 0.0

def show(state):
    try:
        xres, yres, xres_v, bpp, ll = fb_idle.fb_info()
        img, _ = fb_idle.draw(xres, yres, xres_v, bpp, ll, state)
        fb_idle.write(img, xres, yres, xres_v, bpp, ll)
        print("screen:", state, flush=True)
    except Exception as e:
        print("draw failed:", e, flush=True)

def renderer_ready():
    """gmediarender Ready: its UPnP port accepts TCP on our eth0 address."""
    import socket
    try:
        d = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        d.connect(("8.8.8.8", 80))
        myip = d.getsockname()[0]
        d.close()
        s = socket.socket()
        s.settimeout(2)
        try:
            s.connect((myip, 49494))
            return True
        finally:
            s.close()
    except Exception:
        return False

# startup indicator, then wait for renderer readiness
show("starting")
deadline = time.time() + 300
while not renderer_ready():
    if time.time() > deadline:
        show("starting")
        time.sleep(30)
        continue
    time.sleep(2)
show("ok")

proc = subprocess.Popen(
    ["journalctl", "-u", "gmediarender", "-f", "--no-pager", "-o", "cat"],
    stdout=subprocess.PIPE, text=True, errors="replace")

for line in proc.stdout:
    if ("STOPPED" in line or "NO_MEDIA_PRESENT" in line or
            "Transition Requested to STOPPED" in line):
        now = time.time()
        if now - last > DEBOUNCE:
            last = now
            for delay in (2.5, 6.0):
                time.sleep(delay)
                try:
                    xres, yres, xres_v, bpp, ll = fb_idle.fb_info()
                    img, _ = fb_idle.draw(xres, yres, xres_v, bpp, ll)
                    fb_idle.write(img, xres, yres, xres_v, bpp, ll)
                    print("idle drawn", flush=True)
                except Exception as e:
                    print("idle draw failed:", e, flush=True)
