#!/bin/bash

# Setup age keys for SOPS from 1Password

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Setting up age keys for SOPS...${NC}"

# Check if op CLI is installed
if ! command -v op &> /dev/null; then
    echo -e "${RED}Error: 1Password CLI (op) is not installed${NC}"
    echo "Install it from: https://developer.1password.com/docs/cli/get-started/"
    exit 1
fi

# Check if signed in to 1Password
if ! op account list &> /dev/null; then
    echo -e "${RED}Error: Not signed in to 1Password${NC}"
    echo "Run: eval \$(op signin)"
    exit 1
fi

# Create directory if it doesn't exist
AGE_DIR="/home/ben/.config/sops/age"
mkdir -p "$AGE_DIR"

# Retrieve the age key from 1Password and write to file
echo -e "${YELLOW}Retrieving age keys from 1Password...${NC}"
op read "op://Private/age for sops/keys.txt" > "$AGE_DIR/keys.txt"

# Set proper permissions (read/write for user only)
chmod 600 "$AGE_DIR/keys.txt"

echo -e "${GREEN}✓ Age keys successfully set up at $AGE_DIR/keys.txt${NC}"
