#!/bin/bash
timedatectl set-timezone Asia/Shanghai
timedatectl set-ntp true
sleep 1
timedatectl
echo '--- date ---'
date
echo TZ-DONE
