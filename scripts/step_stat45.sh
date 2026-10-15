#!/bin/bash
L=$(journalctl -u gmediarender --since '2026-10-09 14:10:00' --no-pager)
echo "=== 统计时段内事件 ==="
echo "$L" | grep -c 'Dropping frame due to QoS' | xargs echo 'QoS丢帧总数:'
echo "$L" | grep -c 'too late' | xargs echo 'sink too-late 告警:'
echo "$L" | grep -c 'buffers are being dropped' | xargs echo '大量丢帧告警:'
echo '=== 播放时长参考 ==='
echo "$L" | grep -E 'TransportState: PLAYING' | head -1
echo "$L" | tail -1
echo '=== 丢帧时间分布(每10秒) ==='
echo "$L" | grep 'Dropping frame due to QoS' | awk '{print substr($3,1,7)}' | sort | uniq -c | tail -20
echo '=== CPU ==='
top -b -n2 -d2 | grep 'Cpu(s)' | tail -1
echo STAT-DONE
