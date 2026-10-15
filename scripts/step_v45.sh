#!/bin/bash
echo '=== 服务重启事件 ==='
journalctl -u gmediarender --since '2026-10-09 15:00:00' --no-pager | grep -E 'systemd|Started|Stopping|Scheduled|Main PID' | grep -v gmediarender | tail -8
echo '=== 当前会话时长与丢帧 ==='
journalctl -u gmediarender --since '2026-10-09 15:08:00' --no-pager | grep -c QoS
journalctl -u gmediarender --since '2026-10-09 15:08:00' --no-pager | grep 'TransportState: PLAYING' | tail -1
journalctl -u gmediarender -n 5 --no-pager | grep -E 'TransportState' | tail -1
echo V-DONE
