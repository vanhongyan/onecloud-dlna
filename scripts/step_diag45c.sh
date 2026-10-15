#!/bin/bash
echo '=== 进程/线程 ==='
pidof gmediarender
ls /proc/$(pidof gmediarender)/task | wc -l
echo '=== 最近5分钟全部日志 ==='
journalctl -u gmediarender --since '-10 min ago' --no-pager | grep -vE 'grender-|SCPD.xml' | tail -40
echo '=== 49494 监听 ==='
ss -lun | grep 49494 || echo NO-49494
echo '=== SSDP 嗅探(2秒) ==='
timeout 3 tcpdump -i eth0 -c 5 -n udp port 1900 2>/dev/null | head -8 || echo no-tcpdump
echo '=== iptables ==='
iptables -L INPUT -n 2>/dev/null | head -10
echo DIAG3-DONE
