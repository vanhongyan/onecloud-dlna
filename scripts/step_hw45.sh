#!/bin/bash
echo '=== V4L2 设备 ==='
ls -l /dev/video* /dev/media* 2>/dev/null || echo no-video-dev
echo '=== vdec 驱动 ==='
grep -r vdec /proc/devices 2>/dev/null | head -3
lsmod | grep -E 'vdec|h264|codec' | head -5
dmesg 2>/dev/null | grep -iE 'vdec|h264|v4l2|m2m' | tail -10
echo '=== gst 硬件解码元素 ==='
gst-inspect-1.0 v4l2h264dec 2>/dev/null | head -5 || echo no-v4l2h264dec
gst-inspect-1.0 v4l2slh264dec 2>/dev/null | head -5 || echo no-v4l2slh264dec
echo HW-DONE
