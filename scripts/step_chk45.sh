#!/bin/bash
echo '=== B站播放中 CPU ==='
top -b -n2 -d1 | grep -E 'Cpu|gmediarender' | tail -6
echo '=== gmediarender 源码目录 ==='
ls -d /home/src/* /root/src/* /tmp/gmrender* 2>/dev/null
echo '=== 播放状态 ==='
journalctl -u gmediarender --since '-3 min ago' --no-pager 2>/dev/null | grep -E 'TransportState|End-of-stream' | tail -4
echo CHK-DONE
