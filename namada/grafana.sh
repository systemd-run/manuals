#!/bin/bash

green="\e[32m"
pink="\e[35m"
reset="\e[0m"

json_data=$(curl -s http://localhost:26657/status)
namada_address=$(echo "$json_data" | jq -r '.result.validator_info.address')
network=$(echo "$json_data" | jq -r '.result.node_info.network')

touch .bash_profile
source .bash_profile
echo -e "${green}************************${reset}"

# Update and upgrade the system
echo -e "${green}*************Update and upgrade the system*************${reset}"

apt-get update -y
apt-get upgrade -y

# Install necessary dependencies
echo -e "${green}*************Install necessary dependencies*************${reset}"
apt-get install -y curl tar wget original-awk gawk netcat

set -e

# Ensure the script is run as root
echo -e "${green}*************Ensure the script is run as root*************${reset}"
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Function to check the status of a service
echo -e "${green}*************Function to check the status of a service***********${reset}"
check_service_status() {
  service_name="$1"
  if systemctl is-active --quiet "$service_name"; then
    echo "$service_name is running."
  else
    echo "$service_name is not running."
  fi
}


# Create necessary directories
echo -e "${green}*************Create necessary directories***********${reset}"

# An array of directories to be created
directories=("/var/lib/prometheus" "/etc/prometheus/rules" "/etc/prometheus/rules.d" "/etc/prometheus/files_sd")

# Iterate through the array
for dir in "${directories[@]}"; do
  # Check if directory exists and is not empty
  if [ -d "$dir" ] && [ "$(ls -A $dir)" ]; then
    echo "$dir already exists and is not empty. Skipping..."
  else
    mkdir -p "$dir"
    echo "Created directory: $dir"
  fi
done


# Download and extract Prometheus
echo -e "${green}*************Download and extract Prometheus***********${reset}"
cd $HOME
rm -rf prometheus*
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
sleep 1
tar xvf prometheus-2.45.0.linux-amd64.tar.gz
rm prometheus-2.45.0.linux-amd64.tar.gz
cd prometheus*/

if [ -d "/etc/prometheus/consoles" ] && [ "$(ls -A /etc/prometheus/consoles)" ]; then
  echo "/etc/prometheus/consoles directory exists and is not empty. Skipping..."
else
  mv consoles /etc/prometheus/
fi

if [ -d "/etc/prometheus/console_libraries" ] && [ "$(ls -A /etc/prometheus/console_libraries)" ]; then
  echo "/etc/prometheus/console_libraries directory exists and is not empty. Skipping..."
else
  mv console_libraries /etc/prometheus/
fi

mv prometheus promtool /usr/local/bin/


# Define the content to be added
echo -e "${green}**************Define the content to be added**********${reset}"
if [ -f "/etc/prometheus/prometheus.yml" ]; then
  rm "/etc/prometheus/prometheus.yml"
fi
sudo tee /etc/prometheus/prometheus.yml<<EOF
global:
  scrape_interval: 15s
  evaluation_interval: 15s
alerting:
  alertmanagers:
    - static_configs:
        - targets: []

rule_files: []
scrape_configs:
  - job_name: "prometheus"
    metrics_path: /metrics
    static_configs:
      - targets: ["localhost:9345"]
  - job_name: "namada"
    scrape_interval: 5s
    metrics_path: /
    static_configs:
      - targets: ['localhost:26660']
EOF

# Create Prometheus service
echo -e "${green}************Create Prometheus service***********${reset}"

sudo tee /etc/systemd/system/prometheus.service<<EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=root
ExecReload=/bin/kill -HUP \$MAINPID
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries \
  --web.listen-address=0.0.0.0:9344
Restart=always
[Install]
WantedBy=multi-user.target
EOF


# Reload systemd, enable, and start Prometheus
echo -e "${green}**************Reload systemd, enable, and start Prometheus**********${reset}"
systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

# Check Prometheus service status
echo -e "${green}***********Check Prometheus service status*************${reset}"
check_service_status "prometheus"

# Install Grafana
echo -e "${green}**************Install Grafana**********${reset}"
apt-get install -y apt-transport-https software-properties-common wget
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
echo "deb https://packages.grafana.com/enterprise/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list
apt-get update -y
apt-get install grafana-enterprise -y
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

# Check Grafana service status
echo -e "${green}************Check Grafana service status************${reset}"
check_service_status "grafana-server"

# Get the real IP address of the server
echo -e "${green}*************Get the real IP address of the server***********${reset}"
real_ip=$(hostname -I | awk '{print $1}')

# Check Prometheus service status again
echo -e "${green}************Check Prometheus service status again************${reset}"
check_service_status "prometheus"

# Install and start Prometheus Node Exporter
echo -e "${green}*************Install and start Prometheus Node Exporter***********${reset}"
apt install prometheus-node-exporter -y

service_file="/etc/systemd/system/prometheus-node-exporter.service"

if [ -e "$service_file" ]; then
    rm "$service_file"
    echo "File $service_file removed."
else
    echo "File $service_file does not exist."
fi

sudo tee /etc/systemd/system/prometheus-node-exporter.service<<EOF
[Unit]
Description=prometheus-node-exporter
Wants=network-online.target
After=network-online.target
[Service]
Type=simple
User=$USER
ExecStart=/usr/bin/prometheus-node-exporter --web.listen-address=0.0.0.0:9345
Restart=always
[Install]
WantedBy=multi-user.target
EOF

systemctl enable prometheus-node-exporter
systemctl start prometheus-node-exporter

# New port number grafana
echo -e "${green}*************New port number grafana***********${reset}"
# Grafana configuration file path
grafana_config_file="/etc/grafana/grafana.ini"
# New port number
new_port="9346"
# Check if the Grafana configuration file exists
if [ ! -f "$grafana_config_file" ]; then
  echo "Grafana configuration file not found: $grafana_config_file"
  exit 1
fi
# Replace the port number in the configuration file
sed -i "s/^;http_port = .*/http_port = $new_port/" "$grafana_config_file"
# Restart the Grafana service
systemctl restart grafana-server
# Check Grafana service status
echo -e "${green}************Check Grafana service status************${reset}"
check_service_status "grafana-server"

# Change config
echo -e "${green}*************Change config prometheus ON ***********${reset}"
file_path="$HOME/.local/share/namada/$CHAIN_ID/config.toml"
search_text="prometheus = false"
replacement_text="prometheus = true"

# Check if the replacement text already exists in the file
if grep -qFx "$replacement_text" "$file_path"; then
  echo "Replacement text already exists. No changes needed."
else
  # Replace the search text with the replacement text
  sed -i "s/$search_text/$replacement_text/g" "$file_path"
  echo "Text replaced successfully."
fi

search_text2='namespace = "namada_tm"'
replacement_text2='namespace = "namadan_tm"'

# Check if the replacement text already exists in the file
if grep -qFx "$replacement_text2" "$file_path"; then
  echo "Replacement text already exists. No changes needed."
else
  # Replace the search text with the replacement text
  sed -i "s/$search_text2/$replacement_text2/g" "$file_path"
  echo "Text replaced successfully."
fi

# Reload systemd
echo -e "${green}**************RESTART systemd**********${reset}"
systemctl restart prometheus-node-exporter
systemctl restart prometheus
systemctl restart grafana-server
systemctl restart namadad

sleep 3

check_service_status "prometheus-node-exporter"
check_service_status "prometheus"
check_service_status "grafana-server"
check_service_status "namadad"

sleep 1

echo -e "${green}*************Install OK***********${reset}"
echo -e "${green}**********************************${reset}"
echo -e "${green}**********************************${reset}"
echo -e "${green}Grafana is accessible at: ${reset} http://$real_ip:$new_port"
echo -e "${pink}Login credentials:${reset}"
echo -e "${pink}---------Username:${reset} admin"
echo -e "${pink}---------Password:${reset} admin"
echo -e "${green}**********************************${reset}"
echo -e "${pink} Open grafana and add to Home/Connections/Your_connections/Data_sources  ${reset}"
echo -e "${pink} ...new source prometheus with address${reset} http://localhost:9344 "
echo -e "${pink} ...click SAVE and TEST button  ${reset}"
echo -e "${green}**********************************${reset}"
echo -e "${green}**********************************${reset}"
echo -e "${pink} ...then import to Home/Dashboards/Import_dashboard new dashboard    ${reset}"
echo -e "${pink} ...Import NAMADA Dashboard   via grafana.com ${reset}  ID = 19014  "
echo -e "${pink} ...Import Node Exporter Full via grafana.com ${reset}  ID = 1860  "
echo -e "${pink} Change Validator ${reset}          $namada_address  "
echo -e "${pink} Change Chain_ID  ${reset}          $network  "
echo -e "${green}**********************************${reset}"
echo -e "${green}**********************************${reset}"
check_service_status "namadad"
