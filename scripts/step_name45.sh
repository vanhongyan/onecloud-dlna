#!/bin/bash
set -e
sed -i 's/-f OneCloud-TV /-f OneCloud-TV-45 /' /etc/systemd/system/gmediarender.service
systemctl daemon-reload
systemctl restart gmediarender
sleep 2
systemctl is-active gmediarender
tr '\0' ' ' < /proc/$(pidof gmediarender)/cmdline | grep -o '\-f [A-Za-z0-9-]*'
echo NAME-DONE
