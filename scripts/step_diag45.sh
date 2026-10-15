#!/bin/bash
# 诊断：投屏新URI不生效（疑似进程卡死）
set -x
echo '=== gmediarender 进程 ==='
ps -eo pid,ppid,pcpu,etime,stat,comm,args | grep -E 'gmediarender|PID' | grep -v grep
echo '=== 服务状态 ==='
systemctl is-active gmediarender; systemctl status gmediarender --no-pager -n 5 | tail -15
echo '=== 事件日志 cast_test.log ==='
tail -60 /tmp/cast_test.log 2>/dev/null || echo 'no log'
echo '=== journal 最近30行 ==='
journalctl -u gmediarender -n 30 --no-pager | tail -30
echo '=== CPU 占用前5 ==='
ps -eo pcpu,pid,comm --sort=-pcpu | head -6
echo 'DIAG-DONE'
