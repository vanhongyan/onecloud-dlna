#!/bin/bash
echo '=== 最近2分钟 QOS/告警 ==='
journalctl -u gmediarender --since '-2 min' --no-pager 2>/dev/null | grep -E 'QoS|too late|buffers are being dropped' | tail -5
journalctl -u gmediarender --since '2026-10-09 13:35:00' --no-pager | grep -E 'QoS|too late|dropped' | tail -5
echo '=== 线程级CPU(采样5s) ==='
top -b -H -n2 -d5 -p $(pidof gmediarender) | grep -E 'R|S .*%CPU' | sort -k9 -rn | head -12
echo '=== 全系统CPU ==='
top -b -n2 -d3 | grep 'Cpu(s)' | tail -1
echo '=== 中断负载 ==='
cat /proc/loadavg
echo C-DONE
