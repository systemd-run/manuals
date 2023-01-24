# IBC relayer for Planq

## Update system
```
sudo apt update && sudo apt upgrade -y
```

## Make hermes home dir
```
mkdir $HOME/.hermes
```

## Download Hermes
```
wget -nv https://github.com/informalsystems/hermes/releases/download/v1.2.0/hermes-v1.2.0-x86_64-unknown-linux-gnu.tar.gz
mkdir -p $HOME/.hermes/bin
tar -C $HOME/.hermes/bin/ -vxzf hermes-v1.2.0-x86_64-unknown-linux-gnu.tar.gz
echo 'export PATH="$HOME/.hermes/bin:$PATH"' >> $HOME/.bash_profile
source $HOME/.bash_profile
```
## Build Hermes from source (optional)
If "GLIBC... not found..." error is displayed install hermes from source:
```
git clone https://github.com/informalsystems/hermes.git
cd hermes
git checkout v1.2.0
cargo build --release --bin hermes --locked
chmod +x target/release/hermes
mv target/release/hermes /root/go/bin/
```

## Create hermes config
Generate hermes config file.
For Planq, use your values rpc_addr, grpc_addr, websocket_addr.
Also everywhere replace "memo_prefix" with your own value.
```
sudo tee $HOME/.hermes/config.toml > /dev/null <<EOF
# The global section has parameters that apply globally to the relayer operation.
[global]
log_level = 'info'

# Specify the mode to be used by the relayer. [Required]
[mode]

# Specify the client mode.
[mode.clients]
enabled = true
refresh = true
misbehaviour = false

# Specify the connections mode.
[mode.connections]
enabled = false

# Specify the channels mode.
[mode.channels]
enabled = false

# Specify the packets mode.
[mode.packets]
enabled = true
clear_interval = 100
clear_on_start = true
tx_confirmation = false

# The REST section defines parameters for Hermes' built-in RESTful API.
# https://hermes.informal.systems/rest.html
[rest]
enabled = true
host = '0.0.0.0'
port = 53000

[telemetry]
enabled = true
host = '0.0.0.0'
port = 53001

############################################################### PLANQ #########################################################
[[chains]]
id = 'planq_7070-2'
rpc_addr = 'http://127.0.0.1:14657'
grpc_addr = 'http://127.0.0.1:1490'
websocket_addr = 'ws://127.0.0.1:14657/websocket'

rpc_timeout = '30s'
account_prefix = 'plq'
key_name = 'relayer'
address_type = { derivation = 'ethermint', proto_type = { pk_type = '/ethermint.crypto.v1.ethsecp256k1.PubKey' } }
store_prefix = 'ibc'
default_gas = 10000000
max_gas = 40000000
gas_price = { price = 30000000000, denom = 'aplanq' }
gas_multiplier = 1.3
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '7days'
memo_prefix = 'Relayed by cagie'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-2'], # cosmoshub-4
  ['transfer', 'channel-1'], # osmosis
  ['transfer', 'channel-0'], # gravitybridge
  ['transfer', 'channel-22'], # umee
]

############################################################### COSMOS ##########################################################
[[chains]]
id = 'cosmoshub-4'
rpc_addr = 'https://cosmos-rpc.polkachu.com:443'
grpc_addr = 'http://cosmos-grpc.polkachu.com:14990'
websocket_addr = 'wss://rpc.cosmos.bh.rocks:443/websocket'

rpc_timeout = '30s'
account_prefix = 'cosmos'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 180000
max_gas = 2000000
gas_price = { price = 0.01, denom = 'uatom' }
gas_multiplier = 1.2
max_msg_num = 30
max_tx_size = 180000
clock_drift = '15s'
max_block_time = '30s'
trusting_period = '14days'
memo_prefix = 'Relayed by cagie'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-446'], # Planq
]

############################################################### OSMOSIS ##########################################################
[[chains]]
id = 'osmosis-1'
rpc_addr = 'https://osmosis-rpc.polkachu.com:443'
grpc_addr = 'http://osmosis-grpc.polkachu.com:12590'
websocket_addr = 'wss://osmosis-rpc.polkachu.com:443/websocket'

rpc_timeout = '30s'
account_prefix = 'osmo'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 400000
max_gas = 120000000
gas_price = { price = 0.0025, denom = 'uosmo' }
gas_multiplier = 1.5
max_msg_num = 30
max_tx_size = 1800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '7days'
memo_prefix = 'Relayed by cagie'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-492'], # Planq
]

############################################################### GRAVITY BRIDGE ##################################################
[[chains]]
id = 'gravity-bridge-3'
rpc_addr = 'https://gravity-rpc.polkachu.com:443'
grpc_addr = 'http://gravity-grpc.polkachu.com:14290'
websocket_addr = 'wss://rpc.gravity.bh.rocks:443/websocket'

rpc_timeout = '30s'
account_prefix = 'gravity'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 300000
max_gas = 5000000
gas_price = { price = 0.0261, denom = 'ugraviton' }
gas_multiplier = 1.4
max_msg_num = 30
max_tx_size = 800000
clock_drift = '5s'
max_block_time = '30s'
trusting_period = '7days'
memo_prefix = 'Relayed by cagie'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-102'], # Planq
]

############################################################### UMEE ########################################################
[[chains]]
id = 'umee-1'
rpc_addr = 'https://umee-rpc.polkachu.com:443'
grpc_addr = 'http://umee-grpc.polkachu.com:13690'
websocket_addr = 'wss://rpc-umee-ia.cosmosia.notional.ventures:443/websocket'

rpc_timeout = '20s'
account_prefix = 'umee'
key_name = 'relayer'
address_type = { derivation = 'cosmos' }
store_prefix = 'ibc'
default_gas = 100000
max_gas = 2000000
gas_price = { price = 0.001, denom = 'uumee' }
gas_multiplier = 1.2
max_msg_num = 30
max_tx_size = 1800000
clock_drift = '15s'
max_block_time = '10s'
trusting_period = '7days'
memo_prefix = 'Relayed by cagie'
trust_threshold = { numerator = '1', denominator = '3' }

[chains.packet_filter]
policy = 'allow'
list = [
  ['transfer', 'channel-41'], # Planq
]
EOF
```

## Verify hermes configuration is correct
Before proceeding further please check if your configuration is correct
```
hermes health-check
```

## Recover wallets using mnemonic files
Before you proceed with this step, please make sure you have created and funded with tokens seperate wallets on each chain.
When creating a wallet in Planq, you must use the command:
```
planqd keys add <wallet_name> --coin-type 118
```

Add Planq wallet to Hermes:
```
MNEMONIC='...'
CHAIN_ID=planq_7070-2

echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
```

Add Cosmos wallet to Hermes:
```
MNEMONIC='...'
CHAIN_ID=cosmoshub-4

echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
```

Add Osmosis wallet to Hermes:
```
MNEMONIC='...'
CHAIN_ID=osmosis-1

echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
```

Add Gravity Bridge wallet to Hermes:
```
MNEMONIC='...'
CHAIN_ID=gravity-bridge-3

echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
```

Add Umee wallet to Hermes:
```
MNEMONIC='...'
CHAIN_ID=umee-1

echo "$MNEMONIC" > $HOME/.hermes.mnemonic
hermes keys add --chain "$CHAIN_ID" --mnemonic-file $HOME/.hermes.mnemonic
rm $HOME/.hermes.mnemonic
```
## Enabling an index on a Planq node

An index must be included on the Planq node (index = "kv").
To enable the index, use the command:
```
sed -i -e 's|^indexer *=.*|indexer = "kv"|' $HOME/.planqd/config/config.toml
```
## Create hermes service daemon
```
sudo tee /etc/systemd/system/hermesd.service > /dev/null <<EOF
[Unit]
Description=hermes
After=network-online.target

[Service]
User=$USER
ExecStart=$(which hermes) start
Restart=on-failure
RestartSec=3
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
```
```
sudo systemctl daemon-reload
sudo systemctl enable hermesd
sudo systemctl restart hermesd && journalctl -u hermesd -f -o cat
```

## Send transaction
### Send Planq token from Planq to destination chain (osmosis, cosmos, gravity bridge):
Osmosis:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain osmosis-1 --src-chain planq_7070-2 --src-port transfer --src-channel channel-1 --amount <amount planq> --denom aplanq
```
Cosmos:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain cosmoshub-4 --src-chain planq_7070-2 --src-port transfer --src-channel channel-2 --amount <amount planq> --denom aplanq
```
Gravity Bridge:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain gravity-bridge-3 --src-chain planq_7070-2 --src-port transfer --src-channel channel-0 --amount <amount planq> --denom aplanq
```
Umee:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain umee-1 --src-chain planq_7070-2 --src-port transfer --src-channel channel-22 --amount <amount planq> --denom aplanq
```
### Send Planq token from Osmosis, Cosmos, Gravity Bridge to Planq:
Osmosis:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain planq_7070-2 --src-chain osmosis-1 --src-port transfer --src-channel channel-492 --amount <amount planq> --denom ibc/B1E0166EA0D759FDF4B207D1F5F12210D8BFE36F2345CEFC76948CE2B36DFBAF
```
Cosmos:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain planq_7070-2 --src-chain cosmoshub-4 --src-port transfer --src-channel channel-446 --amount <amount planq> --denom ibc/1452F322F7B459CB7EC111AD5BD2404552B011375002C8C85BA615A95B9121CF
```
Gravity Bridge:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain planq_7070-2 --src-chain gravity-bridge-3 --src-port transfer --src-channel channel-102 --amount <amount planq> --denom ibc/2782B87D755389B565D59F15E202E6E3B8B3E1408034D2FAA4E02A0CA10911B2
```
Umee:
```
hermes tx ft-transfer --timeout-height-offset 10 --number-msgs 1 --dst-chain planq_7070-2 --src-chain umee-1 --src-port transfer --src-channel channel-41 --amount <amount planq> --denom ibc/AFD3377FA11440EE2C0A876C618F32EF3A55308536F9C316A37AB362B1343E7A
```

## Check transaction
You can see your transactions here:</br>
https://www.mintscan.io/osmosis/relayers/channel-492 </br>
https://www.mintscan.io/gravity-bridge/relayers/channel-102</br>
https://www.mintscan.io/cosmos/relayers/channel-446</br>
https://www.mintscan.io/umee/relayers/channel-41</br>
https://explorer.planq.network/accounts/<planq_wallet_address></br>

Your address should appear in the "Operator Address" section (on mintscan). After sending transactions, it may take some time for it to appear there.
