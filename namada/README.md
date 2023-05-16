## UPDATE for new release
```bash

#CHECK your vars in /.bash_profile and change if they not correctly
sed -i '/public-testnet/d' "$HOME/.bash_profile"
sed -i '/NAMADA_TAG/d' "$HOME/.bash_profile"
sed -i '/WALLET_ADDRESS/d' "$HOME/.bash_profile"

NEWTAG=v0.15.3
NEWCHAINID=public-testnet-8.0.b92ef72b820

echo "export BASE_DIR=$HOME/.local/share/namada" >> ~/.bash_profile
echo "export NAMADA_TAG=$NEWTAG" >> ~/.bash_profile
echo "export CHAIN_ID=$NEWCHAINID" >> ~/.bash_profile
source ~/.bash_profile

mkdir $BASE_DIR
rustup update

sudo apt install unzip -y
PROTOC_ZIP=protoc-3.14.0-linux-x86_64.zip
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v3.14.0/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
rm -f $PROTOC_ZIP

protoc --version

cd $HOME/namada
git fetch && git checkout $NAMADA_TAG
make build dev-deps

cd $HOME && sudo systemctl stop namadad 

rm /usr/local/bin/namada /usr/local/bin/namadac /usr/local/bin/namadan /usr/local/bin/namadaw

cd $HOME && cp "$HOME/namada/target/debug/namada" /usr/local/bin/namada && \
cp "$HOME/namada/target/debug/namadac" /usr/local/bin/namadac && \
cp "$HOME/namada/target/debug/namadan" /usr/local/bin/namadan && \
cp "$HOME/namada/target/debug/namadaw" /usr/local/bin/namadaw

namada --version

## Output
#Namada v0.15.3

rm -r $HOME/.namada/public-testnet*
rm -r $HOME/.namada/namada-internal*
rm $HOME/.namada/global-config.toml

rm -r $BASE_DIR/public-testnet*
rm -r $BASE_DIR/namada-internal*
rm $BASE_DIR/global-config.toml

#for POST genesis validator
namada client utils join-network --chain-id $CHAIN_ID  

cd $HOME && wget "https://github.com/heliaxdev/anoma-network-config/releases/download/public-testnet-8.0.b92ef72b820/public-testnet-8.0.b92ef72b820.tar.gz"
tar xvzf "$HOME/public-testnet-8.0.b92ef72b820.tar.gz"

sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat 

#check only height logs
sudo journalctl -u namadad -n 10000 -f -o cat | grep height

#end--------------------------------------------------------------


#for PRE genesis validator
cp -r .namada/pre-genesis $BASE_DIR/
namada client utils join-network --chain-id $CHAIN_ID --genesis-validator $VALIDATOR_ALIAS
sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat 
#end--------------------------------------------------------------

## Output
[2023-02-22] service start module=main msg="Starting Node service" impl=Node
[2023-02-22] Genesis time is in the future. Sleeping until then... module=main genTime="******"

#then go to /Make wallet and run validator/ section

```

## namada setup  
```bash
#install update and libs
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config libssl-dev libclang-dev -y
sudo apt install jq build-essential bsdmainutils git make ncdu gcc git-core chrony liblz4-tool -y
sudo apt install libclang-12-dev uidmap dbus-user-session protobuf-compiler -y

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

echo "export NAMADA_TAG=v0.15.3" >> ~/.bash_profile
echo "export TM_HASH=v0.1.4-abciplus" >> ~/.bash_profile
echo "export CHAIN_ID=public-testnet-8.0.b92ef72b820" >> ~/.bash_profile
echo "export WALLET=wallet" >> ~/.bash_profile
echo "export BASE_DIR=$HOME/.local/share/namada" >> ~/.bash_profile

#***CHANGE parameters !!!!!!!!!!!!!!!!!!!!!!!!!!!!***
echo "export VALIDATOR_ALIAS=YOUR_MONIKER" >> ~/.bash_profile

source ~/.bash_profile

cd $HOME && git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG
make build dev-deps


cd $HOME && git clone https://github.com/heliaxdev/tendermint && cd tendermint && git checkout $TM_HASH
make build

cd $HOME && cp $HOME/tendermint/build/tendermint  /usr/local/bin/tendermint && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw

tendermint version
namada --version

#run fullnode
cd $HOME && namada client utils join-network --chain-id $CHAIN_ID

cd $HOME && wget "https://github.com/heliaxdev/anoma-network-config/releases/download/public-testnet-8.0.b92ef72b820/public-testnet-8.0.b92ef72b820.tar.gz"
tar xvzf "$HOME/public-testnet-8.0.b92ef72b820.tar.gz"

#Make service
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=NAMADA_LOG=debug
Environment=NAMADA_TM_STDOUT=true
ExecStart=/usr/local/bin/namada --base-dir=$HOME/.local/share/namada node ledger run 
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

#waiting full synchronization

# check "catching_up": false  --- is OK
curl -s localhost:26657/status

#Make wallet and run validator

cd $HOME
namada wallet address gen --alias $WALLET --unsafe-dont-encrypt

namada client transfer \
  --source faucet \
  --target $WALLET \
  --token NAM \
  --amount 1000 \
  --signer $WALLET

cd $HOME
namada client init-validator \
--alias $VALIDATOR_ALIAS \
--source $WALLET \
--commission-rate 0.05 \
--max-commission-rate-change 0.01 \
--signer $WALLET \
--gas-amount 100000000 \
--gas-token NAM \
--scheme ed25519 \
--unsafe-dont-encrypt


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

#check epoch number
namada client epoch

#stake your funds
#waiting  2 epoch and continue if you get INFO atest1... doesn't belong to any known validator account.
namada client bond \
--validator $VALIDATOR_ALIAS \
--amount 1789 \
--signer $VALIDATOR_ALIAS \
--source $VALIDATOR_ALIAS

#print your validator address

RAW_ADDRESS=`cat "$HOME/.namada/$CHAIN_ID/wallet.toml" | grep address`
WALLET_ADDRESS=$(echo -e $RAW_ADDRESS | sed 's|.*=||' | sed -e 's/^ "//' | sed -e 's/"$//')
echo "export WALLET_ADDRESS=$WALLET_ADDRESS" >> ~/.bash_profile
source ~/.bash_profile
echo -e "\033[32m YOUR WALLET ADDRESS: \033[35m $WALLET_ADDRESS"

#waiting more than 2 epoch and check your status
namada client bonded-stake --validator $VALIDATOR_ALIAS
namada client bonds --validator $VALIDATOR_ALIAS

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
