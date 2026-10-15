#!/bin/bash
journalctl -u gmediarender --since '2026-10-09 13:09:20' --no-pager \
 | grep -vE 'grender-|SCPD.xml|Registering|LastChange|InstanceID|val=|Event xmlns|</' \
 | head -40
echo FLOW-DONE
