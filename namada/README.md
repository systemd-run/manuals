## namada setup

```bash
sudo apt-get update -y
sudo apt-get install build-essential make pkg-config libssl-dev libclang-dev -y
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh


echo "export NAMADA_TAG=v0.12.0" >> ~/.bash_profile
echo "export TM_HASH=v0.1.4-abciplus" >> ~/.bash_profile
source ~/.bash_profile


sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential \

bsdmainutils git make ncdu gcc git jq chrony liblz4-tool -y

sudo apt install -y uidmap dbus-user-session


git clone https://github.com/anoma/namada && cd namada && git checkout $NAMADA_TAG


make build-release


cargo --version


cd $HOME
  sudo apt update
  sudo curl https://sh.rustup.rs -sSf | sh -s -- -y
  . $HOME/.cargo/env
  curl https://deb.nodesource.com/setup_16.x | sudo bash
  sudo apt install curl make clang pkg-config libssl-dev build-essential git jq nodejs -y < "/dev/null"
  sudo apt install npm


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


cd && git clone https://github.com/heliaxdev/tendermint && cd tendermint && git checkout $TM_HASH
make build


cd && cp ~/tendermint/build/tendermint  /usr/local/bin/tendermint && \

cp "$HOME/namada/target/release/namada" /usr/local/bin/namada && \ 

cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac && \

cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan && \

cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw


tendermint version


namada --version
```

## can it start ?

```bash
namada client utils join-network --chain-id $CHAIN_ID
```
*sample output:*

```bash
root@vmi1128207:~# rm -rf .namada/public-testnet-1.0.05ab4adb9db
root@vmi1128207:~# namada client utils join-network --chain-id $CHAIN_ID
Downloading config release from https://github.com/heliaxdev/anoma-network-config/releases/download/public-testnet-1.0.05ab4adb9db/public-testnet-1.0.05ab4adb9db.tar.gz ...
Fetching wasms for chain ID public-testnet-1.0.05ab4adb9db...
2022-12-20T21:05:34.669636Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_init_proposal.b9a77bc9e416f33f1e715f25696ae41582e1b379422f7a643549884e0c73e9de.wasm...
2022-12-20T21:05:34.669813Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_init_account.e21cfd7e96802f8e841613fb89f1571451401d002a159c5e9586855ac1374df5.wasm...
2022-12-20T21:05:34.669718Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/vp_masp.5620cb6e555161641337d308851c760fbab4f9d3693cfd378703aa55e285249d.wasm...
2022-12-20T21:05:34.669980Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/vp_validator.59e3e7729e14eeacc17d76b736d1760d59a1a6e9d6acbc9a870e1835438f524a.wasm...
2022-12-20T21:05:34.680810Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_reveal_pk.47bc922a8be5571620a647ae442a1af7d03d05d29bef95f0b32cdfe00b11fee9.wasm...
2022-12-20T21:05:34.684883Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_ibc.13daeb0c88abba264d3052129eda0713bcf1a71f6f69bf37ec2494d0d9119f1f.wasm...
2022-12-20T21:05:34.694678Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/vp_implicit.17f5c2af947ccfadce22d0fffecde1a1b4bc4ca3acd5dd8b459c3dce4afcb4e8.wasm...
2022-12-20T21:05:34.694690Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/vp_user.b83b2d0616bb2244c8a92021665a0be749282a53fe1c493e98c330a6ed983833.wasm...
2022-12-20T21:05:34.694704Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_init_validator.1e9732873861c625f239e74245f8c504a57359c06614ba40387a71811ca4a097.wasm...
2022-12-20T21:05:34.697572Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_change_validator_commission.cd861e0e82f4934be6d8382d6fff98286b4fadbc20ab826b9e817f6666021273.wasm...
2022-12-20T21:05:34.708952Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/vp_token.a289723dd182fe0206e6c4cf1f426a6100787b20e2653d2fad6031e8106157f3.wasm...
2022-12-20T21:05:34.718304Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_update_vp.ee2e9b882c4accadf4626e87d801c9ac8ea8c61ccea677e0532fc6c1ee7db6a2.wasm...
2022-12-20T21:05:34.722326Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_withdraw.6ce8faf6a32340178ddeaeb91a9b40e7f0433334e5c1f357964bf8e11d0077f1.wasm...
2022-12-20T21:05:34.727475Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_vote_proposal.263fd9f4cb40f283756f394d86bdea3417e9ecd0568d6582c07a5b6bd14287d6.wasm...
2022-12-20T21:05:34.737790Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_transfer.bbd1ef5d9461c78f0288986de046baad77e10671addc5edaf3c68ea1ae4ecc99.wasm...
2022-12-20T21:05:34.749904Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_bond.be9c75f96b3b4880b7934d42ee218582b6304f6326a4588d1e6ac1ea4cc61c49.wasm...
2022-12-20T21:05:34.751003Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/vp_testnet_faucet.362584b063cc4aaf8b72af0ed8af8d05a179ebefec596b6ab65e0ca255ec3c80.wasm...
2022-12-20T21:05:34.754102Z  INFO namada_apps::wasm_loader: Downloading WASM https://namada-wasm-master.s3.eu-west-1.amazonaws.com/tx_unbond.c0a690d0ad43a94294a6405bae3327f638a657446c74dc61dbb3a4d2ce488b5e.wasm...
Successfully configured for chain ID public-testnet-1.0.05ab4adb9db
```
