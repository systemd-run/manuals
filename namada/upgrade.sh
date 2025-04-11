#!/bin/bash

set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log() {
    echo -e "${CYAN}==>${NC} $1"
}

success() {
    echo -e "${GREEN}[?]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[?]${NC} $1"
    exit 1
}

# Set environment variables
NAMADA_TAG="v1.1.5"
CBFT="v0.40.3"

log "Cleaning previous Namada and CometBFT directories..."
rm -rf "$HOME/namada" "$HOME/cometbft"

log "Cloning and building Namada ($NAMADA_TAG)..."
cd "$HOME"
git clone https://github.com/anoma/namada
cd namada
git checkout "$NAMADA_TAG"
make build-release || error "Failed to build Namada"
success "Namada built successfully"

log "Cloning and building CometBFT ($CBFT)..."
cd "$HOME"
git clone https://github.com/cometbft/cometbft.git
cd cometbft
git checkout "$CBFT"
make build || error "Failed to build CometBFT"
success "CometBFT built successfully"

log "Stopping existing Namada daemon..."
sudo systemctl stop namadad || warn "Namada daemon not running"

log "Copying built binaries to /usr/local/bin..."
sudo cp "$HOME/cometbft/build/cometbft" /usr/local/bin/cometbft
sudo cp "$HOME/namada/target/release/namada" /usr/local/bin/namada
sudo cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac
sudo cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan
sudo cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw
success "Binaries copied"

log "Checking versions..."
cometbft version || error "Failed to get CometBFT version"
namada --version || error "Failed to get Namada version"

log "Starting Namada daemon..."
sudo systemctl start namadad
success "Namada daemon started"

log "Tailing Namada daemon logs (press Ctrl+C to exit)..."
sleep 5
sudo journalctl -u namadad -o cat -n 100

sleep 5
log "Waiting for node to fully synchronize..."
while true; do
    SYNC_STATUS=$(curl -s localhost:26657/status | grep catching_up)
    echo -e "${YELLOW}${SYNC_STATUS}${NC}"
    if echo "$SYNC_STATUS" | grep -q "false"; then
        success "Node is fully synchronized"
        break
    else
        warn "Node is still catching up... rechecking in 5 seconds"
        sleep 5
    fi
done
