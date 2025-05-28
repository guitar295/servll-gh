#!/bin/bash

set -e

echo "🔄 Cập nhật hệ thống và cài đặt Docker, curl, openssl..."
sudo apt-get update -y
sudo apt-get install -y docker.io curl openssl

echo "✅ Khởi động và kích hoạt Docker..."
sudo systemctl unmask docker.service docker.socket containerd.service || true
sudo systemctl restart containerd
sudo systemctl start docker
sudo systemctl enable docker

# Tạo SECRET định dạng chuẩn: 'ee' + 16 bytes hex
SECRET=ee$(openssl rand -hex 16)
echo "🔐 SECRET proxy: $SECRET"

# Xóa container cũ nếu có
if sudo docker ps -a --format '{{.Names}}' | grep -q '^mtproto-proxy$'; then
  echo "🧹 Xóa container cũ mtproto-proxy..."
  sudo docker rm -f mtproto-proxy
fi

echo "🚀 Chạy MTProto Proxy trên cổng 8443, image hỗ trợ ARM64..."

sudo docker run --platform linux/arm64/v8 -d \
  --name mtproto-proxy \
  --restart always \
  -p 8443:443 \
  -e SECRET=$SECRET \
  telegrammessenger/proxy:arm64

sleep 5

IP=$(curl -s ifconfig.me)

echo ""
echo "✅ Proxy đã chạy!"
echo "Dùng các link sau để kết nối Telegram:"
echo "tg://proxy?server=$IP&port=8443&secret=$SECRET"
echo "https://t.me/proxy?server=$IP&port=8443&secret=$SECRET"
echo ""
echo "📝 Kiểm tra trạng thái container với: sudo docker ps"
