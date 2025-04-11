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

log "Checking Namada version..."
namada --version || error "Failed to get Namada version"

log "Starting Namada daemon..."
sudo systemctl start namadad
success "Namada daemon started"

log "Waiting for Namada node to fully initialize..."
TIMEOUT=600
SLEEP_INTERVAL=3
CHECK_COUNT=0
FOUND_NODE_STARTED=0
FOUND_VALIDATOR=0

while [ $CHECK_COUNT -lt $((TIMEOUT / SLEEP_INTERVAL)) ]; do
    LOG_OUTPUT=$(journalctl -u namadad -n 100 --no-pager 2>/dev/null)

    if echo "$LOG_OUTPUT" | grep -q "Namada ledger node started"; then
        FOUND_NODE_STARTED=1
    fi
    if echo "$LOG_OUTPUT" | grep -q "This node is a validator"; then
        FOUND_VALIDATOR=1
    fi

    if [ "$FOUND_NODE_STARTED" -eq 1 ] && [ "$FOUND_VALIDATOR" -eq 1 ]; then
        success "Namada node is running and identified as validator"
        break
    fi

    warn "Waiting for Namada to fully start... ($((CHECK_COUNT * SLEEP_INTERVAL))s elapsed)"
    sleep $SLEEP_INTERVAL
    CHECK_COUNT=$((CHECK_COUNT + 1))
done

if [ "$FOUND_NODE_STARTED" -ne 1 ]; then
    error "Timeout: Namada ledger node did not start properly."
fi

if [ "$FOUND_VALIDATOR" -ne 1 ]; then
    error "Timeout: Node did not announce itself as a validator."
fi

log "Waiting for node to fully synchronize..."
SYNC_RETRY=0
SYNC_MAX_RETRY=600

while true; do
    STATUS_JSON=$(curl -s localhost:26657/status || echo "")
    
    if [ -z "$STATUS_JSON" ]; then
        warn "RPC not ready yet... waiting ($((SYNC_RETRY * 5))s elapsed)"
    else
        CATCHING_UP=$(echo "$STATUS_JSON" | grep catching_up | grep -oE 'true|false')
        echo -e "${YELLOW}[$(date '+%H:%M:%S')] catching_up = $CATCHING_UP${NC}"
        
        if [ "$CATCHING_UP" = "false" ]; then
            success "Node is fully synchronized"
            break
        fi
    fi

    SYNC_RETRY=$((SYNC_RETRY + 1))
    if [ "$SYNC_RETRY" -ge "$SYNC_MAX_RETRY" ]; then
        error "Timeout: Node did not synchronize after $((SYNC_MAX_RETRY * 5)) seconds"
    fi

    sleep 5
done

