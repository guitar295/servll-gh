#!/bin/bash

echo "🔄 Cập nhật hệ thống và cài Docker..."
sudo apt-get update -y
sudo apt-get install docker.io curl -y

echo "✅ Khởi động Docker..."
sudo systemctl unmask docker.service
sudo systemctl unmask docker.socket
sudo systemctl unmask containerd.service
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

echo "🚀 Khởi chạy MTProto Proxy trên PORT 8443..."
sudo docker run -d \
 --name=$CONTAINER_NAME \
 --restart=always \
 -p 8443:443 \
 -p 80:80 \
 -p 8888:8443 \
 -e SECRET=$SECRET \
 -e TAG='myproxytag' \
 telegrammessenger/proxy

sleep 3

echo "📡 Đang lấy thông tin kết nối..."
sudo docker logs $CONTAINER_NAME 2>&1 | grep -E 'tg://|t.me'

echo ""
echo "✅ CÀI ĐẶT HOÀN TẤT!"
echo "💡 Hãy sao chép link trên và mở trong Telegram để sử dụng."
