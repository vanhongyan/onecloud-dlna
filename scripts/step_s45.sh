#!/bin/bash
systemctl is-active gmediarender
pidof gmediarender || echo NO-PID
ss -ltnp | grep 49494 || echo NO-PORT
journalctl -u gmediarender -n 25 --no-pager | grep -vE 'grender-|SCPD.xml' | tail -25
echo S-DONE
