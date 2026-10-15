#!/bin/bash
systemctl restart gmediarender
sleep 3
systemctl is-active gmediarender
pidof gmediarender
ls /proc/$(pidof gmediarender)/task | wc -l
journalctl -u gmediarender -n 3 --no-pager | tail -3
ss -lun | grep 49494 && echo UPNP-OK
echo RESTART-DONE
