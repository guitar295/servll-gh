
bash <(curl -Ls https://raw.githubusercontent.com/guitar295/servll-gh/main/serv00.sh)

Settup MTProto:

curl -sL https://raw.githubusercontent.com/guitar295/servll-gh/refs/heads/main/mtproto.sh | bash

Lấy lại thông tin:

sudo docker logs mtproto-proxy 2>&1 | grep -E 'tg://|t.me'
