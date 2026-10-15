#!/bin/bash
set -e
cp /tmp/fb_idle.py /tmp/fb_watch.py /home/src/
chmod +x /home/src/fb_idle.py
# unit: unbind fbcon and run idle watcher
cat > /etc/systemd/system/gm-idle.service <<'EOF'
[Unit]
Description=gmrender idle screen watcher
After=gmediarender.service
Requires=gmediarender.service

[Service]
Type=simple
ExecStartPre=/bin/sh -c 'echo 0 > /sys/class/vtconsole/vtcon1/bind || true'
ExecStart=/usr/bin/python3 /home/src/fb_watch.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now gm-idle.service
sleep 3
systemctl is-active gm-idle.service
python3 /home/src/fb_idle.py
echo ====IDLE_END
