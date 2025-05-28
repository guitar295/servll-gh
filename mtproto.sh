#!/bin/bash

set -e

# Cài đặt các dependencies
sudo apt-get update -y
sudo apt-get install -y git make gcc erlang-dev erlang-public-key erlang-ssl libssl-dev curl openssl

# Tạo thư mục làm việc
WORK_DIR="$HOME/mtproxy_build"
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# Clone mã nguồn
if [ ! -d "mtproto_proxy" ]; then
  git clone https://github.com/seriyps/mtproto_proxy.git
fi
cd mtproto_proxy

# Build
make

# Tạo secret
SECRET=ee$(openssl rand -hex 16)
echo "SECRET: $SECRET"

# Tạo file cấu hình
cat >config/prod-sys.config <<EOL
[
 {mtproto_proxy,
  [
   {ports,
    [
     {8443,
      [{secret, <<"$SECRET">>},
       {tag, <<"proxy">>}]
      }
    ]}
  ]},
  {lager,
   [
    {log_root, "/var/log/mtproto-proxy"}
   ]}
].
EOL

# Tạo systemd service
sudo tee /etc/systemd/system/mtproto-proxy.service > /dev/null <<EOL
[Unit]
Description=MTProto Proxy
After=network.target

[Service]
Type=simple
WorkingDirectory=$WORK_DIR/mtproto_proxy
ExecStart=$WORK_DIR/mtproto_proxy/bin/mtproto-proxy run
User=$USER
Group=$USER
Restart=always
RestartSec=30

[Install]
WantedBy=multi-user.target
EOL

# Khởi động service
sudo systemctl daemon-reload
sudo systemctl enable mtproto-proxy
sudo systemctl start mtproto-proxy

# Lấy IP public
IP=$(curl -s ifconfig.me)

echo ""
echo "Proxy đã được cài đặt thành công!"
echo "Link Telegram:"
echo "tg://proxy?server=$IP&port=8443&secret=$SECRET"
echo "https://t.me/proxy?server=$IP&port=8443&secret=$SECRET"
echo ""
echo "Để quản lý service:"
echo "• Xem trạng thái: sudo systemctl status mtproto-proxy"
echo "• Khởi động lại: sudo systemctl restart mtproto-proxy"
echo "• Xem log: journalctl -u mtproto-proxy -f"
