#!/bin/bash
echo '=== 重启后是否有新投屏会话 ==='
journalctl -u gmediarender --since '2026-10-09 15:00:00' --no-pager | grep -E 'TransportState: PLAYING|Set uri' | tail -3
echo '=== QoS 丢帧统计 ==='
L=$(journalctl -u gmediarender --since '2026-10-09 15:00:00' --no-pager)
echo "$L" | grep -c 'Dropping frame due to QoS' | xargs echo 'QoS丢帧总数:'
echo '=== 丢帧分布(每10秒) ==='
echo "$L" | grep 'Dropping frame due to QoS' | awk '{print substr($3,1,7)}' | sort | uniq -c | tail -15
echo '=== CPU ==='
top -b -n2 -d2 | grep 'Cpu(s)' | tail -1
echo S-DONE
