#!/bin/bash
echo '=== 当前状态 ==='
journalctl -u gmediarender -n 200 --no-pager | grep -E 'TransportState' | tail -2
echo '=== 负载 ==='
top -b -n2 -d2 | grep 'Cpu(s)' | tail -1
cat /proc/loadavg
echo S-DONE
