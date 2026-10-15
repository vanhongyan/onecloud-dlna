#!/bin/bash
pkill -f 'journalctl -f -u gmediarender' 2>/dev/null
: > /tmp/cast_test.log
nohup bash -c 'journalctl -f -u gmediarender --no-pager | grep --line-buffered -E "TransportState|AVTransportURI:|End-of-stream"' >/dev/null 2>&1 &
sleep 1
pgrep -fc 'journalctl -f -u gmediarender'
date '+NOW %H:%M:%S'
echo WATCHER-OK
