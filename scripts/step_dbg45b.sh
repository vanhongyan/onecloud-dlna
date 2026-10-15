#!/bin/bash
journalctl -u gmediarender --since '2026-10-09 13:08:00' --no-pager \
 | grep -E 'WARN|ERROR|buffer|Buffer|QOS|drop|Drop|clock|underrun' \
 | grep -v 'LastChange' | tail -40
echo DBG-DONE
