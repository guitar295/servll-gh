
bash <(curl -Ls https://raw.githubusercontent.com/guitar295/servll-gh/main/serv00.sh)

Settup MTProto:

curl -sL https://raw.githubusercontent.com/guitar295/servll-gh/refs/heads/main/mtproto.sh | bash

bash <(curl -Ls https://raw.githubusercontent.com/guitar295/servll-gh/main/mtproto-arm.sh)

Lấy lại thông tin:

sudo docker logs mtproto-proxy 2>&1 | grep -E 'tg://|t.me'

HƯỚNG DẪN TẠO PROXY TRUY CẬP TELEGRAM
5/26/2025 06:19:00 CH
 MTPROTO Proxy | Ubuntu


Bài viết này hướng dẫn bạn tạo Proxy dạng MTPROTO trên Ubuntu VPS để thêm vào ứng dụng Telegram để có thể truy cập ở Việt Nam



NGUYÊN LIỆU



1. VPS nước ngoài chạy Ubuntu có thể truy cập Telegram không bị chặn (Azure, Google, AWS...)



CÁC BƯỚC THỰC HIỆN



B1:



Cập nhật hệ thống Ubuntu và cài đặt Docker

Mở terminal và gõ:



sudo apt-get update

sudo apt-get install docker.io -y

sudo systemctl start docker

sudo systemctl enable docker



Nếu lỗi liên quan đến docker services thì bạn nhập các lệnh sau:

sudo systemctl unmask docker.socket && sudo systemctl unmask docker.service && sudo systemctl unmask containerd && sudo systemctl restart containerd

Sau đó là:

sudo systemctl start docker

Nếu không có lỗi gì ở B1 thì chuyển sang B2


B2:


Mở terminal và gõ:


sudo docker run -d \
 --name=iaman95-mtproto-telegram-proxy \
 --restart=always \
 -p 443:443 \
 -p 80:80 \
 -p 8443:8443 \
 -e SECRET=$(head -c 16 /dev/urandom | xxd -ps) \
 -e TAG='iaman95-mtproto-telegram-proxy' \
 telegrammessenger/proxy


Mô tả:

name: Tên của Container (Bạn đặt tuỳ ý)
p 443:443 > Port mặc định, port này chính là port thông số nhập vào Telegram
p 80:80 > Fallback port
p 8443:8443 >Dự phòng
SECRET: Mặc định sẽ random 16 ký tự bất kỳ (Nếu bạn muốn đặt lại thì có thể nhập vào đó)
TAG: Bạn nhập tuỳ ý
telegrammessenger/proxy: Đây là source proxy trên Git https://github.com/TelegramMessenger/MTProxy



B3:


Sau khi khởi tạo thành công, bạn tiến hành lấy thông tin kết nối

Mở terminal và gõ:


sudo docker logs iaman95-mtproto-telegram-proxy 2>&1 | grep secret


<iaman95-mtproto-telegram-proxy> Chính là tên của Container của bạn



Hệ thống sẽ trả về kết quả:

[*]   tg:// link for secret 1 auto configuration: tg://proxy?server=xxx.xxx.xxx.xxx&port=443&secret=x1fb62dex126e9e6bf11xdf77d9730dc
[*]   t.me link for secret 1: https://t.me/proxy?server=xxx.xxx.xxx.xxx&port=443&secret=x1fb62dex126e9e6bf11xdf77d9730dc


Bạn sẽ có được thông số kết nối dạng thế này:

Server: xxx.xxx.xxx.xxx
Port: 443
Secret: x1fb62dex126e9e6bf11xdf77d9730dc





Lưu ý: Đối với các VPS trên Azure, AWS, Google...các bạn kiểm tra xem là đã cho phép Inbound/Outbound đối với các cổng trên hay chưa nhé đặt biệt là phần Firewall trên trang quản trị VPS.

Đối với bản thân VPS thì nếu bạn bật Firewall thì phải tiến hành cho phép các cổng trên, nếu không bật thì thôi, tuỳ vào hệ điều hành VPS mà sẽ có cách đóng/mở khác nhau




MỘT SỐ LỆNH LIÊN QUAN ĐẾN DOCKER


# Dừng Container

sudo docker stop <Tên container của bạn>

sudo docker stop iaman95-mtproto-telegram-proxy


# Đổi tên Container

sudo docker rename <Tên container cũ> <Tên container mới>

sudo docker rename mtproto-proxy iaman95-mtproto-telegram-proxy


# Chạy Container

sudo docker start <Tên container của bạn>

sudo docker start iaman95-mtproto-telegram-proxy


# Dừng Container

sudo docker stop <Tên container của bạn>

sudo docker stop iaman95-mtproto-telegram-proxy-container


# Xoá container

sudo docker rm iaman95-mtproto-telegram-proxy-container




OPTIONAL: HƯỚNG DẪN FIREWALL TRÊN UBUNTU


# Kiểm tra trạng thái Firewall

sudo ufw status



# Cài đặt (Nếu chưa có)

sudo apt update
sudo apt install ufw



# Bật (Nếu đã cài đặt)

sudo ufw enable



# Cho phép Inbound các cổng 80, 443, 8443

sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 8443/tcp



# Cho phép Outbound các cổng 80, 443, 8443

sudo ufw default allow outgoing

# Hoặc nếu đang chặn mặc định:
sudo ufw allow out 80/tcp
sudo ufw allow out 443/tcp
sudo ufw allow out 8443/tcp



# Kiểm tra

sudo ufw status verbose




# Đối với máy chủ ARM 

bash
CopyEdit
# Biến tạm
SECRET=$(head -c 16 /dev/urandom | xxd -ps)
IMAGE_NAME="mtproto-proxy-arm64"
CONTAINER_NAME="mtproto-proxy"
PORT=443
IP=$(curl -s ifconfig.me)

# Clone nếu chưa có
if [ ! -d "mtprotoproxy" ]; then
  git clone https://github.com/alexbers/mtprotoproxy.git
fi
cd mtprotoproxy

# Ghi file cấu hình config.py
cat > config.py <<EOF
PORT=443
USERS = {
    'default': '$SECRET'
}
EOF

# Build image
docker build -t $IMAGE_NAME .

# Xoá container cũ (nếu có)
docker rm -f $CONTAINER_NAME 2>/dev/null

# Chạy container
docker run -d \
  --name $CONTAINER_NAME \
  --restart=always \
  -p ${PORT}:443 \
  -p 80:80 \
  -p 8443:8443 \
  $IMAGE_NAME



