df -h / | tail -1
cat > /tmp/install.sh <<'EOF'
#!/bin/bash
exec >/tmp/install.log 2>&1
apt-get update
DEBIAN_FRONTEND=noninteractive apt-get install -y gstreamer1.0-tools gstreamer1.0-plugins-base gstreamer1.0-plugins-good gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-alsa alsa-utils build-essential git autoconf automake libtool pkg-config libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libglib2.0-dev
echo APT_DONE
EOF
chmod +x /tmp/install.sh
nohup /tmp/install.sh >/dev/null 2>&1 &
echo STARTED
