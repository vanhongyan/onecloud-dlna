#!/bin/bash
apt-get install -y -qq fbset 2>&1 | tail -1
fbset -fb /dev/fb0 -xres 1280 -yres 720 -vxres 1280 -vyres 720 -depth 24 2>&1 || echo FBSET-FAIL
sleep 1
cat /sys/class/graphics/fb0/virtual_size; cat /sys/class/graphics/fb0/bits_per_pixel
echo SET-DONE
