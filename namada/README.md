## UPDATE for new release
```bash

cd $HOME/namada

NEWTAG=v0.13.2

git fetch && git checkout $NEWTAG

make build-release

cd $HOME && sudo systemctl stop namadad

rm /usr/local/bin/namada /usr/local/bin/namadac /usr/local/bin/namadan /usr/local/bin/namadaw

cd $HOME && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && \
cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && \
cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && \
cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw

namada --version

## Output
Namada v0.13.2

cd $HOME && wget "https://github.com/heliaxdev/anoma-network-config/releases/download/public-testnet-2.1.4014f207f6d/public-testnet-2.1.4014f207f6d.tar.gz"

tar xvzf "$HOME/public-testnet-2.1.4014f207f6d.tar.gz"

namada client utils join-network --chain-id public-testnet-2.1.4014f207f6d

sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat

## Output
I[2023-01-24|09:37:17.504] service start                                module=main msg="Starting Node service" impl=Node
I[2023-01-24|09:37:17.504] Genesis time is in the future. Sleeping until then... module=main genTime="2023-01-24 17:00:00 +0000 UTC"
```

## namada setup  
```bash
#install update and libs
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libclang-dev -y
sudo apt install jq build-essential bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y
sudo apt install -y uidmap dbus-user-session


cd $HOME
  sudo apt update
  sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
  . $HOME/.cargo/env
  curl https://deb.nodesource.com/setup_16.x | sudo bash
  sudo apt install cargo nodejs -y < "/dev/null"
  cargo --version
  
if ! [ -x "$(command -v go)" ]; then
  ver="1.19.4"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

#Setting up vars

echo "export NAMADA_TAG=v0.13.2" >> ~/.bash_profile
echo "export TM_HASH=v0.1.4-abciplus" >> ~/.bash_profile
echo "export CHAIN_ID=public-testnet-2.1.4014f207f6d" >> ~/.bash_profile
echo "export WALLET=wallet" >> ~/.bash_profile

#***CHANGE parameters !!!!!!!!!!!!!!!!!!!!!!!!!!!!***
echo "export VALIDATOR_ALIAS=YOUR_MONIKER" >> ~/.bash_profile

source ~/.bash_profile

cd $HOME && git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG
make build-release


cd $HOME && git clone https://github.com/heliaxdev/tendermint && cd tendermint && git checkout $TM_HASH
make build

cd $HOME && cp $HOME/tendermint/build/tendermint  /usr/local/bin/tendermint && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw

tendermint version
namada --version

#run fullnode
cd $HOME && namada client utils join-network --chain-id $CHAIN_ID

cd $HOME && wget "https://github.com/heliaxdev/anoma-network-config/releases/download/public-testnet-2.1.4014f207f6d/public-testnet-2.1.4014f207f6d.tar.gz"
tar xvzf "$HOME/public-testnet-2.1.4014f207f6d.tar.gz"

#Make service
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=root
WorkingDirectory=$HOME/.namada
Environment=NAMADA_LOG=debug
Environment=NAMADA_TM_STDOUT=true
ExecStart=/usr/local/bin/namada --base-dir=$HOME/.namada node ledger run 
StandardOutput=syslog
StandardError=syslog
Restart=always
RestartSec=10
LimitNOFILE=65535
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable namadad
sudo systemctl start namadad

#add  peers
#cd $HOME
#sudo systemctl stop namadad
#rm "$HOME/.namada/public-testnet-2.1.4014f207f6d/tendermint/config/addrbook.json"
#curl -s https://raw.githubusercontent.com/systemd-run/manuals/main/namada/addrbook.json > $HOME/.namada/public-testnet-2.1.4014f207f6d/tendermint/config/addrbook.json
#sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat

#waiting full synchronization

# check "catching_up": false  --- is OK
curl -s localhost:26657/status

#Make wallet and run validator

cd $HOME
namada wallet address gen --alias $WALLET

namada client transfer \
  --source faucet \
  --target $WALLET \
  --token NAM \
  --amount 1000 \
  --signer $WALLET

cd $HOME
namada client init-validator --alias $VALIDATOR_ALIAS --source $WALLET --commission-rate 0.05 --max-commission-rate-change 0.01 --gas-limit 10000000

#enter pass

cd $HOME
namada client transfer \
    --token NAM \
    --amount 1000 \
    --source faucet \
    --target $VALIDATOR_ALIAS \
    --signer $VALIDATOR_ALIAS
	
#use faucet again because min stake 1000 and you need some more NAM
namada client transfer \
    --token NAM \
    --amount 1000 \
    --source faucet \
    --target $VALIDATOR_ALIAS \
    --signer $VALIDATOR_ALIAS
	
#check balance
namada client balance --owner $VALIDATOR_ALIAS --token NAM

#stake your funds
namada client bond \
  --validator $VALIDATOR_ALIAS \
  --amount 1500 \
  --gas-limit 10000000
  
#print your validator address
export WALLET_ADDRESS=`cat "$HOME/.namada/public-testnet-2.1.4014f207f6d/wallet.toml" | grep address`
echo -e '\n\e[45mYour wallet:' $WALLET_ADDRESS '\e[0m\n'

#waiting more than 2 epoch and check your status
namada client bonded-stake



#check only height logs
sudo journalctl -u namadad -n 10000 -f -o cat | grep height

#DELETE NODE!!!
systemctl stop namadad && systemctl disable namadad
rm /etc/systemd/system/namadad* -rf
rm $(which namadad) -rf
rm $HOME/.namada* -rf
rm $HOME/namada -rf
rm $HOME/tendermint -rf

```
