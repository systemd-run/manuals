## UPDATE for new release v0.23.2

```bash
cd $HOME 
sudo apt update && sudo apt upgrade -y

sed -i '/NAMADA_TAG/d' "$HOME/.bash_profile"
NEWTAG=v0.23.2
echo "export NAMADA_TAG=$NEWTAG" >> ~/.bash_profile
source ~/.bash_profile

cd $HOME/namada
git reset --hard HEAD
git fetch && git checkout $NEWTAG
make build-release
#cargo fix --lib -p namada_apps

systemctl stop namadad 
rm /usr/local/bin/namada /usr/local/bin/namadac /usr/local/bin/namadan /usr/local/bin/namadaw /usr/local/bin/namadar -rf

cd $HOME && cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && \
cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && \
cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && \
cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw && \
cp "$HOME/namada/target/release/namadar" /usr/local/bin/namadar

namada --version
#output: Namada v0.23.2
awk -v new_val="$VALIDATOR_ALIAS" '{ if ($1 == "moniker") $3 = "\"" new_val "\""; print }' "$HOME/.local/share/namada/public-testnet-14.5d79b6958580/config.toml" > temp_file && mv temp_file "$HOME/.local/share/namada/public-testnet-14.5d79b6958580/config.toml"
sudo systemctl start namadad && sudo journalctl -u namadad -f -o cat

```


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
awk -v new_val="$VALIDATOR_ALIAS" '{ if ($1 == "moniker") $3 = "\"" new_val "\""; print }' "$HOME/.local/share/namada/public-testnet-14.5d79b6958580/config.toml" > temp_file && mv temp_file "$HOME/.local/share/namada/public-testnet-14.5d79b6958580/config.toml"
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
awk -v new_val="$VALIDATOR_ALIAS" '{ if ($1 == "moniker") $3 = "\"" new_val "\""; print }' "$HOME/.local/share/namada/public-testnet-14.5d79b6958580/config.toml" > temp_file && mv temp_file "$HOME/.local/share/namada/public-testnet-14.5d79b6958580/config.toml"
sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat
#end--------------------------------------------------------------


#run fullnode post-genesis
cd $HOME && namada client utils join-network --chain-id $NAMADA_CHAIN_ID
sudo systemctl start namadad && sudo journalctl -u namadad -f -o cat 
awk -v new_val="$VALIDATOR_ALIAS" '{ if ($1 == "moniker") $3 = "\"" new_val "\""; print }' "$HOME/.local/share/namada/public-testnet-14.5d79b6958580/config.toml" > temp_file && mv temp_file "$HOME/.local/share/namada/public-testnet-14.5d79b6958580/config.toml"
sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat

#waiting full synchronization
#or use snapshot 
sudo systemctl stop namadad
cd $HOME && wget -c https://snsmln.xyz/data.tar
sudo tar -xvf data.tar -C $HOME/.local/share/namada
sudo systemctl restart namadad && sudo journalctl -u namadad -f -o cat
#WARNING this is experimental feature
#if not working delete folder rm $HOME/.local/share/namada -rf and join-network again


# check "catching_up": false  --- is OK
curl -s localhost:26657/status

#--------------------------------------------------------------
#Make wallet and run validator

#check epoch number
namada client epoch

cd $HOME
namada wallet address gen --alias $WALLET --unsafe-dont-encrypt
namada wallet address find --alias $WALLET

#copy address wallet then use faucet https://faucet.heliax.click/ 
#waiting  2 epoch
#check balance
namada client balance --owner $WALLET --token NAM

#init-validator
cd $HOME
namada client init-validator \
--alias $VALIDATOR_ALIAS \
--commission-rate 0.05 \
--max-commission-rate-change 0.01 \
--signing-keys $WALLET \
--account-keys $WALLET \
--unsafe-dont-encrypt

#waiting  2 epoch
#print your validator address
namada wallet address find --alias $VALIDATOR_ALIAS

#copy address wallet then use faucet https://faucet.heliax.click/
#check balance, should be more than 1001 NAM
namada client balance --owner $VALIDATOR_ALIAS --token NAM

#stake your funds
namada client bond \
--validator $VALIDATOR_ALIAS \
--amount 1002 \
--source $VALIDATOR_ALIAS

#waiting  2 epoch and check your status
namada client bonded-stake --validator $VALIDATOR_ALIAS
namada client bonds --validator $VALIDATOR_ALIAS
namadac validator-state --validator $VALIDATOR_ALIAS

#check only height logs
sudo journalctl -u namadad -n 1000 -f -o cat | grep height
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
