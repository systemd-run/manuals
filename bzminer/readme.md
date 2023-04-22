```
# CHECK DRIVERS CUDA & Nvidia driver , if already installed skip installation.
# GO TO https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64 AND FOLLOW INSTRUCTION
```

```
# INSTALL BZMINER WITH HEROPOOL
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libclang-dev -y

mkdir ironfishminer
cd ironfishminer
wget https://www.bzminer.com/downloads/bzminer_v14.2.2_linux.tar.gz
mkdir -p $HOME/ironfishminer/bzminer
tar xvzf bzminer_v14.2.2_linux.tar.gz -C $HOME/ironfishminer/bzminer --strip-components=1
sudo chmod +x $HOME/ironfishminer/bzminer/bzminer

cd $HOME
sudo tee $HOME/ironfishminer/bzminer.sh > /dev/null <<EOF
#!/bin/bash
#CHANGE !!! YOUR_IRONFISH_WALLET_ADDRESS.YOUR_NICKNAME !!! for example 66e044578b31c6c4c05810b0e5281bdf36138ad41bf6844ba317dc7c506bf9ac.systemd
$HOME/ironfishminer/bzminer/bzminer -a ironfish -w YOUR_IRONFISH_WALLET_ADDRESS.YOUR_NICKNAME -p stratum+tcp://de.ironfish.herominers.com:1145
EOF

sudo chmod +x $HOME/ironfishminer/bzminer.sh

sudo tee /etc/systemd/system/bzminer.service > /dev/null <<EOF
[Unit]
Description=bzminer
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME
ExecStart=$HOME/ironfishminer/bzminer.sh
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable bzminer
sudo systemctl start bzminer
sudo journalctl -u bzminer -f --no-pager --no-hostname -o cat

```
