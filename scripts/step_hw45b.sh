#!/bin/bash
v4l2-ctl -d /dev/video0 --all 2>/dev/null | head -20 || cat /sys/class/video4linux/video0/name
echo '---'
gst-inspect-1.0 2>/dev/null | grep -iE 'v4l2|omx' | head -10
echo '---'
which media-ctl && media-ctl -d /dev/media0 -p 2>/dev/null | head -15
echo DEV-DONE
