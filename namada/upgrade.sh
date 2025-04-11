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
    echo -e "${GREEN}[✔]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[!]${NC} $1"
}

error() {
    echo -e "${RED}[✖]${NC} $1"
    exit 1
}

# Set environment variables
NAMADA_TAG="v1.1.5"

log "Cleaning previous Namada directory..."
rm -rf "$HOME/namada"

log "Cloning and building Namada ($NAMADA_TAG)..."
cd "$HOME"
git clone https://github.com/anoma/namada
cd namada
git checkout "$NAMADA_TAG"
make build-release || error "Failed to build Namada"
success "Namada built successfully"

log "Stopping existing Namada daemon..."
sudo systemctl stop namadad || warn "Namada daemon not running"

log "Copying built binaries to /usr/local/bin..."
sudo cp "$HOME/namada/target/release/namada" /usr/local/bin/namada
sudo cp "$HOME/namada/target/release/namadac" /usr/local/bin/namadac
sudo cp "$HOME/namada/target/release/namadan" /usr/local/bin/namadan
sudo cp "$HOME/namada/target/release/namadaw" /usr/local/bin/namadaw
success "Binaries copied"

log "
