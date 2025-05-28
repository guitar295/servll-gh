
bash <(curl -Ls https://raw.githubusercontent.com/guitar295/servll-gh/main/serv00.sh)

Settup MTProto

curl -sL https://raw.githubusercontent.com/guitar295/servll-gh/refs/heads/main/mtproto.sh | bash

🔧 Cách thức hoạt động

Tự động khởi động cùng hệ thống (systemd service).
Tự động restart nếu bị crash (Restart=always).
Chạy ở chế độ nền (không phụ thuộc vào SSH).
Logs được ghi vào journalctl (dễ debug).
✅ Kiểm tra hoạt động

bash
# Kiểm tra trạng thái
sudo systemctl status mtproto-proxy

# Xem log realtime
journalctl -u mtproto-proxy -f
🛠 Gỡ cài đặt (nếu cần)

bash
sudo systemctl stop mtproto-proxy
sudo systemctl disable mtproto-proxy
sudo rm -rf /opt/mtproto_proxy /etc/systemd/system/mtproto-proxy.service
sudo systemctl daemon-reload
