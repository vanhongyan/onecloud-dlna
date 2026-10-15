#!/bin/bash
echo '=== CPU 总体 ==='
top -b -n1 | head -5
echo '=== gmediarender 线程占用 ==='
top -b -n1 -H -p $(pidof gmediarender) | tail -15
echo '=== 温度/降频 ==='
cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq 2>/dev/null
echo '=== 播放状态确认 ==='
journalctl -u gmediarender --since '2026-10-09 12:00:00' --no-pager | grep -E 'TransportState' | tail -5
echo CPU-DONE
