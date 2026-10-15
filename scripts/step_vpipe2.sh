#!/bin/bash
journalctl -u gmediarender --no-pager --since "15:22" | grep -iv webserver | grep -iE "error|pipe|sink" | tail -6
sed -i 's:--gstout-videopipe=videoscale ! video/x-raw,width=1280,height=720 ! fbdevsink:--gstout-videopipe="videoscale ! video/x-raw,width=1280,height=720 ! fbdevsink":' /etc/systemd/system/gmediarender.service
grep ExecStart /etc/systemd/system/gmediarender.service
systemctl daemon-reload
systemctl restart gmediarender
sleep 5
systemctl is-active gmediarender
echo ====FIX_END
