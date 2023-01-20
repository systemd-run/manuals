Install InfluxDB
=
Installation of InfluxDB on Ubuntu22.04|20.04|18.04 is done from Influxdata repository. Once the repo is added, the package can then be installed using an apt package manager. Add the InfluxData repository to the file  `/etc/apt/sources.list.d/influxdb.list`:
```Bash
# Update packages
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install curl tar wget clang pkg-config libssl-dev jq build-essential bsdmainutils ncdu git jq chrony liblz4-tool -y
```
Add repo to Ubuntu
```Bash
# for Ubuntu 22.04/20.04:
echo "deb https://repos.influxdata.com/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

# for Ubuntu 18.04:
echo "deb https://repos.influxdata.com/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```
Import GPG key
```Bash
sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
```
Update apt index and install InfluxDB
```Bash
sudo apt-get update
sudo apt-get install influxdb
```
Start and enable the service to start on boot up
```Bash
sudo systemctl enable --now influxdb
```
Check service status:
```Bash
sudo systemctl status influxdb
```
Configure the InfluxDB Server
=
Configure a new admin user with root privileges for InfluxDB server.
```Bash
# start the influx shell and connect to the local InfluxDB instance automatically
influx

# create an admin account
CREATE USER <your_name> WITH PASSWORD '<your_password>' WITH ALL PRIVILEGES

# exit from the InfluxDB shell
quit
```
Enabling authentication by modifying the main InfluxDB configuration file
```Bash
sudo nano /etc/influxdb/influxdb.conf
```
Locate the line `# auth-enabled = false` under the `[http]` section. \
Change the value of `auth-enabled` from `false` to `true` and remove the leading `#` symbol from the line to uncomment the setting. \
Restart the `influxdb` service.
```Bash
sudo systemctl restart influxdb
```
Creating an InfluxDB Database
=
Log in to the InfluxDB server with the admin `username` and `password`
```Bash
influx -username '<your_name>' -password '<your_password>'
```
Create the database
```Bash
CREATE DATABASE <database_name>
```
Check our database
```Bash
SHOW DATABASES
```
By default, influxdb service is listening on all interfaces on port `8086`.

Install Telegraf
=
Installation of telegraf on Ubuntu is done from Influxdata repository. Once the repo is added, the package can then be installed using an apt package manager. Add the InfluxData repository to the file  `/etc/apt/sources.list.d/influxdata.list`
```Bash
cat <<EOF | sudo tee /etc/apt/sources.list.d/influxdata.list
deb https://repos.influxdata.com/ubuntu $(lsb_release -cs) stable
EOF
```
Import apt key
```Bash
sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
```
Update apt index and install telegraf
```Bash
sudo apt update
sudo apt install telegraf
```
Start and enable the service to start on boot up
```Bash
sudo systemctl enable --now telegraf
sudo systemctl is-enabled telegraf
```
Check service status
```Bash
sudo systemctl status telegraf
```
Configuring Telegraf
=
Download config `telegraf.conf`
```Bash
sudo mv /etc/telegraf/telegraf.conf /etc/telegraf/telegraf.conf.bak
sudo mv /etc/telegraf/telegraf.conf.sample /etc/telegraf/telegraf.conf.sample.bak
wget -O telegraf.conf https://raw.githubusercontent.com/glukosseth/testnet_guide/main/cosmos/usefull_for_cosmos/monitoring/telegraf.conf
chmod +x telegraf.conf && sudo mv $HOME/telegraf.conf /etc/telegraf/telegraf.conf
```
Open `telegraf.conf`
```Bash
sudo nano /etc/telegraf/telegraf.conf
```
and replace
```Bash
<node_name> - server-hostname with your valid hostname
<database_name> - database-name with InfluxDB database nae for this host
<grafana_ip> - ip address with Grafana installed
<database_login> - auth-username with InfluxDB http authentication username
<database_password> - auth-password with InfluxDB http authentication password.
```
Once all changes have been made, you can restart the telegraf service
```Bash
sudo systemctl restart telegraf && sudo journalctl -u telegraf -f -o cat
```
Enable Prometheus in your validator node. Configure `config.toml` and edit three options:
- prometheus = true
- prometheus_listen_addr = “127.0.0.1:26660” 
- namespace = “tendermint”

![u11](https://user-images.githubusercontent.com/108256873/177996020-44fc90fc-4c2b-4d5f-be7d-4e82a63ae65b.png)

Restart service of your validator


Install Grafana
=
Update your Apt repositories and install Grafana
```Bash
sudo apt-get install -y adduser libfontconfig1 && \
wget https://dl.grafana.com/oss/release/grafana_8.0.6_amd64.deb && \
sudo dpkg -i grafana_8.0.6_amd64.deb
```
Start Grafana service
```Bash
sudo systemctl daemon-reload && \
sudo systemctl enable grafana-server && \
sudo systemctl restart grafana-server && sudo journalctl -u grafana-server -f 
```
