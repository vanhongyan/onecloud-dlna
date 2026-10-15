#!/bin/bash
set -e
python3 - <<'PYEOF'
content = """[Unit]
Description=gmrender-resurrect DLNA media renderer
Wants=network-online.target
After=network-online.target sound.target

[Service]
Type=simple
ExecStartPre=/bin/sh -c 'i=0; until ip -4 addr show eth0 | grep -q "inet 192.168"; do i=$((i+1)); [ $i -gt 60 ] && break; sleep 2; done'
ExecStart=/usr/local/bin/gmediarender --logfile=stdout -I eth0 -f OneCloud-TV -u <REPLACE-WITH-YOUR-UUID> --gstout-audiosink=alsasink --gstout-videopipe="videoscale add-borders=true ! video/x-raw,width=1920,height=1080,pixel-aspect-ratio=1/1 ! fbdevsink"
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
"""
open('/etc/systemd/system/gmediarender.service','w').write(content)
PYEOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 3
systemctl is-active gmediarender
grep -o 'videopipe=.*' /etc/systemd/system/gmediarender.service
journalctl -u gmediarender -n 50 --no-pager | grep -o 'videoscale.*fbdevsink' | tail -1
echo DEPLOY-DONE
