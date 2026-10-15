#!/bin/bash
echo '=== 播放状态 ==='
journalctl -u gmediarender --since '2026-10-09 13:15:00' --no-pager | grep -E 'TransportState: PLAYING|Set uri' | tail -3
echo '=== GST 告警/QOS/丢帧 ==='
journalctl -u gmediarender --since '2026-10-09 13:15:00' --no-pager \
 | grep -E 'WARN|ERROR|QOS|drop|Drop|drop|late|underrun|Underflow|rebuffer' \
 | grep -vE 'LastChange|val=' | tail -30
echo '=== 实时CPU ==='
top -b -n2 -d2 | grep 'Cpu(s)' | tail -2
echo A-DONE
