#!/bin/bash

# === Thông tin ===
IMAGE_NAME="alexbers/mtprotoproxy:arm64"
CONTAINER_NAME="mtproto-proxy-arm64"
PORT="443"
TAG=""  # <-- Thay bằng TAG thực nếu có

# === Kiểm tra Docker ===
if ! command -v docker &> /dev/null; then
  echo "Docker chưa được cài đặt. Vui lòng cài đặt Docker trước khi chạy script này."
  exit 1
fi

# === Tạo SECRET ngẫu nhiên ===
SECRET=$(head -c 16 /dev/urandom | xxd -ps)

# === In ra SECRET để tham khảo sau (nếu cần) ===
echo "➡️  SECRET được tạo: $SECRET"
echo "➡️  TAG sử dụng: $TAG"

# === Clone mã nguồn nếu chưa có ===
if [ ! -d "mtprotoproxy" ]; then
  git clone https://github.com/alexbers/mtprotoproxy.git
fi
cd mtprotoproxy || exit 1

# === Build image cho ARM64 ===
echo "🛠️  Đang build Docker image..."
docker build -t $IMAGE_NAME .

# === Dừng và xóa container cũ (nếu có) ===
docker stop $CONTAINER_NAME 2>/dev/null
docker rm $CONTAINER_NAME 2>/dev/null

# === Chạy container mới ===
echo "🚀 Đang khởi chạy MTProto Proxy container..."
docker run -d --name $CONTAINER_NAME \
  --restart=always \
  -p ${PORT}:443 \
  -p 80:80 \
  -p 8443:8443 \
  -e SECRET=$SECRET \
  -e TAG=$TAG \
  $IMAGE_NAME

# === Lấy địa chỉ IP công khai ===
IP=$(curl -s https://api.ipify.org)

# === In ra link kết nối Telegram ===
echo "✅ Link Telegram Proxy:"
echo "tg://proxy?server=${IP}&port=${PORT}&secret=${SECRET}"
