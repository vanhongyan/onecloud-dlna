#!/bin/bash
sed -i 's:--gstout-videopipe="videoscale ! video/x-raw,width=1280,height=720 ! fbdevsink":--gstout-videopipe="videoflip method=automatic ! videoscale ! video/x-raw,width=1280,height=720 ! fbdevsink":' /etc/systemd/system/gmediarender.service
grep ExecStart /etc/systemd/system/gmediarender.service
systemctl daemon-reload
systemctl restart gmediarender
sleep 5
systemctl is-active gmediarender
echo ====ROT_END
