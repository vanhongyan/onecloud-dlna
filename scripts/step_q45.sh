#!/bin/bash
tr '\0' '\n' < /proc/$(pidof gmediarender)/cmdline | grep -A8 videopipe | head -9
echo V2-DONE
