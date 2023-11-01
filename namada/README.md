## UPDATE for new release v0.23.1

```bash


cd $HOME && mkdir $HOME/namada_backup
cp -r $HOME/.local/share/namada/pre-genesis $HOME/namada_backup/
systemctl stop namadad && systemctl disable namadad
rm /usr/local/bin/namada /usr/local/bin/namadac /usr/local/bin/namadan /usr/local/bin/namadaw /usr/local/bin/namadar -rf
rm $HOME/.local/share/namada -rf
rm -rf $HOME/.masp-params

sudo apt update && sudo apt upgrade -y

#CHECK your vars in /.bash_profile and change if they not correctly
sed -i '/public-testnet/d' "$HOME/.bash_profile"
sed -i '/NAMADA_TAG/d' "$HOME/.bash_profile"
sed -i '/WALLET_ADDRESS/d' "$HOME/.bash_profile"

NEWTAG=v0.23.1
NEWCHAINID=public-testnet-14.5d79b6958580

echo "export BASE_DIR=$HOME/.local/share/namada" >> ~/.bash_profile
echo "export NAMADA_TAG=$NEWTAG" >> ~/.bash_profile
echo "export NAMADA_CHAIN_ID=$NEWCHAINID" >> ~/.bash_profile
source ~/.bash_profile

cd $HOME/namada
git fetch && git checkout $NAMADA_TAG
make build-release
cargo fix --lib -p namada_apps

cd $HOME && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && \
cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && \
cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && \
cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw && \
cp "$HOME/namada/target/release/namadar" /usr/local/bin/namadar
systemctl enable namadad

#check version
namada --version
#output: Namada v0.23.1



#ONLY for PRE genesis validator
#IF YOU NOT A PRE GEN VALIDATOR SKIP THIS SECTION
mkdir $HOME/.local/share/namada
cp -r $HOME/namada_backup/pre-genesis* $BASE_DIR/
namada client utils join-network --chain-id $NAMADA_CHAIN_ID --genesis-validator $VALIDATOR_ALIAS

sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat 
#end--------------------------------------------------------------


#run fullnode post-genesis
cd $HOME && namada client utils join-network --chain-id $NAMADA_CHAIN_ID
sudo systemctl start namadad && sudo journalctl -u namadad -f -o cat 
#end--------------------------------------------------------------

## Output
[2023-**-**] service start module=main msg="Starting Node service" impl=Node
[2023-**-**] Genesis time is in the future. Sleeping until then... module=main genTime="******"

#then go to /Make wallet and run validator/ section


```

## namada setup  
```bash
#install update and libs
cd $HOME
sudo apt update && sudo apt upgrade -y
sudo apt install curl tar wget clang pkg-config git make libssl-dev libclang-dev libclang-12-dev -y
sudo apt install jq build-essential bsdmainutils ncdu gcc git-core chrony liblz4-tool -y
sudo apt install uidmap dbus-user-session protobuf-compiler unzip -y


cd $HOME
  sudo apt update
  sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
  . $HOME/.cargo/env
  curl https://deb.nodesource.com/setup_18.x | sudo bash
  sudo apt install cargo nodejs -y < "/dev/null"
  
cargo --version
node -v
  
if ! [ -x "$(command -v go)" ]; then
  ver="1.20.5"
  cd $HOME
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz"
  sudo rm -rf /usr/local/go
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz"
  rm "go$ver.linux-amd64.tar.gz"
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  source ~/.bash_profile
fi

go version

cd $HOME && rustup update
PROTOC_ZIP=protoc-23.3-linux-x86_64.zip
curl -OL https://github.com/protocolbuffers/protobuf/releases/download/v23.3/$PROTOC_ZIP
sudo unzip -o $PROTOC_ZIP -d /usr/local bin/protoc
sudo unzip -o $PROTOC_ZIP -d /usr/local 'include/*'
rm -f $PROTOC_ZIP

protoc --version

#CHECK your vars in /.bash_profile and change if they not correctly
sed -i '/public-testnet/d' "$HOME/.bash_profile"
sed -i '/NAMADA_TAG/d' "$HOME/.bash_profile"
sed -i '/WALLET_ADDRESS/d' "$HOME/.bash_profile"
sed -i '/CBFT/d' "$HOME/.bash_profile"

#Setting up vars

echo "export NAMADA_TAG=v0.23.1" >> ~/.bash_profile
echo "export CBFT=v0.37.2" >> ~/.bash_profile
echo "export NAMADA_CHAIN_ID=public-testnet-14.5d79b6958580" >> ~/.bash_profile
echo "export WALLET=wallet" >> ~/.bash_profile
echo "export BASE_DIR=$HOME/.local/share/namada" >> ~/.bash_profile

#***CHANGE parameters !!!!!!!!!!!!!!!!!!!!!!!!!!!!***
echo "export VALIDATOR_ALIAS=YOUR_MONIKER" >> ~/.bash_profile

source ~/.bash_profile

cd $HOME && git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG
make build-release
cargo fix --lib -p namada_apps

cd $HOME && git clone https://github.com/cometbft/cometbft.git && cd cometbft && git checkout $CBFT
make build

cd $HOME && cp $HOME/cometbft/build/cometbft /usr/local/bin/cometbft && \
cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && \
cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && \
cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && \
cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw && \
cp "$HOME/namada/target/release/namadar" /usr/local/bin/namadar

cometbft version
namada --version

#Make service
sudo tee /etc/systemd/system/namadad.service > /dev/null <<EOF
[Unit]
Description=namada
After=network-online.target
[Service]
User=$USER
WorkingDirectory=$HOME/.local/share/namada
Environment=TM_LOG_LEVEL=p2p:none,pex:error
Environment=NAMADA_CMT_STDOUT=true
ExecStart=/usr/local/bin/namada node ledger run 
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

#ONLY for PRE genesis validator
#IF YOU NOT A PRE GEN VALIDATOR SKIP THIS SECTION
namada client utils join-network --chain-id $NAMADA_CHAIN_ID --genesis-validator $VALIDATOR_ALIAS
sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat 
#end--------------------------------------------------------------


#run fullnode post-genesis
cd $HOME && namada client utils join-network --chain-id $NAMADA_CHAIN_ID
sudo systemctl start namadad && sudo journalctl -u namadad -f -o cat 

#waiting full synchronization

# check "catching_up": false  --- is OK
curl -s localhost:26657/status

#--------------------------------------------------------------
#Make wallet and run validator

cd $HOME
namada wallet address gen --alias $WALLET --unsafe-dont-encrypt

namada client transfer \
  --source faucet \
  --target $WALLET \
  --token NAM \
  --amount 1000 \
  --signing-keys $WALLET

cd $HOME
namada client init-validator \
--alias $VALIDATOR_ALIAS \
--commission-rate 0.05 \
--max-commission-rate-change 0.01 \
--signing-keys $WALLET \
--account-keys $WALLET \
--unsafe-dont-encrypt


cd $HOME
namada client transfer \
    --token NAM \
    --amount 1000 \
    --source faucet \
    --target $VALIDATOR_ALIAS \
    --signing-keys $VALIDATOR_ALIAS
	
#use faucet again because min stake 1000 and you need some more NAM
namada client transfer \
    --token NAM \
    --amount 1000 \
    --source faucet \
    --target $VALIDATOR_ALIAS \
    --signing-keys $VALIDATOR_ALIAS
	
#check balance
namada client balance --owner $VALIDATOR_ALIAS --token NAM

#check epoch number
namada client epoch

#stake your funds
#waiting  2 epoch and continue if you get INFO atest1... doesn't belong to any known validator account.
namada client bond \
--validator $VALIDATOR_ALIAS \
--amount 1888 \
--source $VALIDATOR_ALIAS

#print your validator address

RAW_ADDRESS=`cat "$HOME/.local/share/namada/$NAMADA_CHAIN_ID/wallet.toml" | grep "address ="`
WALLET_ADDRESS=$(echo -e $RAW_ADDRESS | sed 's|.*=||' | sed -e 's/^ "//' | sed -e 's/"$//')
echo "export WALLET_ADDRESS=$WALLET_ADDRESS" >> ~/.bash_profile
source ~/.bash_profile
echo -e "\033[32m YOUR WALLET ADDRESS: \033[35m $WALLET_ADDRESS"

#waiting more than 2 epoch and check your status
namada client bonded-stake --validator $VALIDATOR_ALIAS
namada client bonds --validator $VALIDATOR_ALIAS

#check only height logs
sudo journalctl -u namadad -n 10000 -f -o cat | grep height
```

## INSTALL GRAFANA MONITORING


```bash
cd $HOME && wget -q -O grafana.sh https://raw.githubusercontent.com/systemd-run/manuals/main/namada/grafana.sh && chmod +x grafana.sh && ./grafana.sh


#Grafana is accessible at: http://localhost:9346
#Login credentials:
#---------Username: admin
#---------Password: admin
#**********************************
# Open grafana and add to Home/Connections/Your_connections/Data_sources
# ...new source prometheus with address http://localhost:9344
# ...click SAVE and TEST button
#**********************************
# ...then import to Home/Dashboards/Import_dashboard new dashboard
# ...Import via grafana.com     ID = 19014
# Change Validator_ID           for example (D2FE325E52DBC76342A8ACA803767290707FC2CA)
# Change NAMADA_Chain_ID               for example (public-testnet-********)
```

## DELETE NODE!!!

```bash
cd $HOME && mkdir $HOME/namada_backup
cp -r $HOME/.local/share/namada/pre-genesis $HOME/namada_backup/
systemctl stop namadad && systemctl disable namadad
rm /etc/systemd/system/namada* -rf
rm $(which namada) -rf
rm /usr/local/bin/namada* /usr/local/bin/cometbft -rf
rm $HOME/.namada* -rf
rm $HOME/.local/share/namada -rf
rm $HOME/namada -rf
rm $HOME/cometbft -rf

```
