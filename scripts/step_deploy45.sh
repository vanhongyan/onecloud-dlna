#!/bin/bash
# <BOX_IP_B> 部署 gmediarender + gm-idle 服务
set -e
cd /tmp
mkdir -p /etc/modules-load.d
cp /tmp/pkg_gmediarender.service /etc/systemd/system/gmediarender.service
cp /tmp/pkg_gm-idle.service /etc/systemd/system/gm-idle.service
cp /tmp/fb_idle.py /tmp/fb_watch.py /home/src/ 2>/dev/null || { mkdir -p /home/src; cp /tmp/fb_idle.py /tmp/fb_watch.py /home/src/; }
echo snd-soc-meson-gx-sound-card > /etc/modules-load.d/gx-sound.conf
systemctl daemon-reload
systemctl enable gmediarender gm-idle
echo DEPLOY-DONE
