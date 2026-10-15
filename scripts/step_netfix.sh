#!/bin/bash
journalctl -u gmediarender -b --no-pager | grep -E "Ready for rendering" | head -2
cat > /etc/systemd/system/gmediarender.service <<'EOF'
[Unit]
Description=gmrender-resurrect DLNA media renderer
Wants=network-online.target
After=network-online.target sound.target

[Service]
Type=simple
ExecStartPre=/bin/sh -c 'i=0; until ip -4 addr show eth0 | grep -q "inet 192.168"; do i=$((i+1)); [ $i -gt 60 ] && break; sleep 2; done'
ExecStart=/usr/local/bin/gmediarender --logfile=stdout -I eth0 -f OneCloud-TV -u <REPLACE-WITH-YOUR-UUID> --gstout-audiosink=alsasink --gstout-videopipe="videoflip method=automatic ! videoscale ! video/x-raw,width=1280,height=720 ! fbdevsink"
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl restart gmediarender
sleep 6
systemctl is-active gmediarender
python3 - <<'PYEOF'
import socket
s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM, socket.IPPROTO_UDP)
s.settimeout(6)
s.setsockopt(socket.IPPROTO_IP, socket.IP_MULTICAST_TTL, 2)
s.bind(("<BOX_IP_A>", 0))
msg = b"M-SEARCH * HTTP/1.1\r\nHOST: 239.255.255.250:1900\r\nMAN: \"ssdp:discover\"\r\nMX: 3\r\nST: ssdp:all\r\n\r\n"
s.sendto(msg, ("239.255.255.250", 1900))
s.sendto(msg, ("239.255.255.250", 1900))
n = 0
try:
    for i in range(10):
        data, addr = s.recvfrom(4096)
        if addr[0] == "<BOX_IP_A>":
            n += 1
except socket.timeout:
    pass
print("SELF_SSDP_RESPONSES", n)
PYEOF
echo ====FIX_END
