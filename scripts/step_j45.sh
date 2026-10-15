#!/bin/bash
echo '=== 播放时段全量非描述日志 ==='
journalctl -u gmediarender --since '2026-10-09 12:40:00' --no-pager | grep -vE 'grender-|SCPD.xml|Registering' | tail -30
echo '=== 当前是否在播 ==='
journalctl -u gmediarender --since '2026-10-09 12:43:00' --no-pager | grep TransportState | tail -3
echo J-DONE
