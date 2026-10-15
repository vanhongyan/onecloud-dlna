#!/bin/bash
journalctl -u gmediarender -n 100 --no-pager | grep -iE 'error|fail|could not|warn' | grep -v LastChange | tail -8
tr '\0' ' ' < /proc/$(pidof gmediarender)/cmdline | grep -o 'videorate.*fbdevsink[^"]*' | head -c 250
echo
ss -ltnp | grep -c 49494
echo E-DONE
