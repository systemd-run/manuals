```bash
apt install llvm clang cmake -y
apt install protobuf-compiler -y
cd $HOME
git clone https://github.com/subspace/subspace-cli.git
cd subspace-cli
git checkout v0.5.0-alpha
export RUSTFLAGS="-C target-cpu=native -C opt-level=3"
export CFLAGS="-march=native"
export CXXFLSGS="$CFLAGS"
cargo build --profile production --bin subspace-cli
rm -rf /usr/local/bin/subspace-cli 
cp -r /$HOME/subspace-cli/target/production/subspace-cli /usr/local/bin/
chmod +x /usr/local/bin/subspace-cli
subspace-cli init
```

```bash
sudo tee <<EOF >/dev/null /etc/systemd/system/subspaced.service
[Unit]
Description=Subspace Node
After=network.target

[Service]
User=root
Type=simple
ExecStart=/usr/local/bin/subspace-cli farm --verbose
Restart=on-failure
LimitNOFILE=1024000

[Install]
WantedBy=multi-user.target
EOF
```

```bash
systemctl daemon-reload
systemctl enable subspaced
systemctl restart subspaced
journalctl -u subspaced -f -o cat
```
