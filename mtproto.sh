#!/bin/bash

echo "🔄 Cập nhật hệ thống và cài Docker..."
sudo apt-get update -y
sudo apt-get install docker.io curl -y

echo "✅ Khởi động Docker..."
sudo systemctl unmask docker.service docker.socket containerd.service
sudo systemctl restart containerd
sudo systemctl start docker
sudo systemctl enable docker

# Tạo SECRET ngẫu nhiên
SECRET=$(head -c 16 /dev/urandom | xxd -ps)

# Đặt tên container
CONTAINER_NAME="mtproto-proxy"

# Nếu container đã tồn tại, xóa trước để tránh lỗi
if [ "$(sudo docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "⚠️ Container $CONTAINER_NAME đã tồn tại. Đang xóa..."
    sudo docker rm -f $CONTAINER_NAME
fi

echo "🚀 Khởi chạy MTProto Proxy ARM64 trên PORT 8443..."
sudo docker run -d \
 --name=$CONTAINER_NAME \
 --restart=always \
 -p 8443:443 \
 -p 80:80 \
 -p 8888:8443 \
 -e SECRET=$SECRET \
 -e TAG='myproxytag' \
seriyps/mtproto-proxy:latest

sleep 3

echo "📡 Đang lấy thông tin kết nối..."
IP=$(curl -s ifconfig.me)
LINK="tg://proxy?server=$IP&port=8443&secret=$SECRET"
LINK2="https://t.me/proxy?server=$IP&port=8443&secret=$SECRET"

echo ""
echo "✅ CÀI ĐẶT HOÀN TẤT!"
echo "💡 Dưới đây là link để bạn sử dụng trong Telegram:"
echo ""
echo "👉 $LINK"
echo "👉 $LINK2"
