#!/bin/bash
echo '=== 端口 ==='
ss -lunp | grep -E '49494|1900' || echo 'NO-UPNP-PORTS'
ss -lnp | grep 49494 || true
echo '=== 重启后全日志(过滤描述文件) ==='
journalctl -u gmediarender --since '2026-10-08 18:37:40' --no-pager | grep -vE 'grender-|SCPD.xml' | tail -50
echo '=== fd/网络 ==='
ls -l /proc/$(pidof gmediarender)/fd 2>/dev/null | grep -c socket
cat /proc/$(pidof gmediarender)/status | grep -E 'State|Threads'
echo DIAG4-DONE
