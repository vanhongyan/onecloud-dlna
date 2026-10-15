#!/bin/bash
echo '=== 全量日志关键事件 ==='
journalctl -u gmediarender --no-pager | grep -Ei 'SetAVTransport|Play\(|Stop\(|Pause|TransportState|ERROR|WARN|CRITICAL|eos|negotiat|failed' | tail -50
echo '=== 日志总行数/最早时间 ==='
journalctl -u gmediarender --no-pager | wc -l
journalctl -u gmediarender --no-pager | head -3
echo '=== gst 线程栈(卡在哪) ==='
for t in /proc/$(pidof gmediarender)/task/*; do echo "-- $(basename $t)"; cat $t/comm 2>/dev/null; cat $t/wchan 2>/dev/null; echo; done | head -60
echo '=== CPU 采样 ==='
top -b -n1 -p $(pidof gmediarender) | tail -3
echo 'DIAG2-DONE'
