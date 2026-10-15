#!/bin/bash
echo '=== 134 最近投屏事件 ==='
journalctl -u gmediarender -n 300 --no-pager 2>/dev/null | grep -E 'TransportState: (PLAYING|STOPPED|PAUSED)|Set uri' | tail -12
echo '=== 134 uuid ==='
tr '\0' ' ' < /proc/$(pidof gmediarender)/cmdline 2>/dev/null | grep -o '\-u [0-9a-f-]*'
echo D-DONE
