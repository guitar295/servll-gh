#!/bin/bash

set -e

sudo apt-get update -y
sudo apt-get install -y docker.io curl openssl

sudo systemctl unmask docker.service docker.socket containerd.service || true
sudo systemctl restart containerd
sudo systemctl start docker
sudo systemctl enable docker

SECRET=ee$(openssl rand -hex 16)
echo "SECRET: $SECRET"

sudo docker rm -f mtproto-proxy 2>/dev/null || true

# Thử image seriyps/mtproto-proxy cho ARM64
sudo docker run --platform linux/arm64/v8 -d \
  --name mtproto-proxy \
  --restart always \
  -p 8443:443 \
  -e SECRET=$SECRET \
  seriyps/mtproto-proxy

sleep 5

IP=$(curl -s ifconfig.me)

echo ""
echo "Proxy đang chạy!"
echo "Link Telegram:"
echo "tg://proxy?server=$IP&port=8443&secret=$SECRET"
echo "https://t.me/proxy?server=$IP&port=8443&secret=$SECRET"
