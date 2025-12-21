#!/usr/bin/env bash

set -e

# Ensure we have access to system binaries
export PATH="/usr/bin:/usr/sbin:$PATH"

echo "=== Upload SSH Key to GitHub ==="
echo

# Default SSH key path
SSH_KEY_PATH="${1:-$HOME/.ssh/id_ed25519}"

# Check if SSH key exists
if [ ! -f "$SSH_KEY_PATH" ]; then
    echo "Error: SSH key not found at $SSH_KEY_PATH"
    echo "Usage: $0 [path-to-ssh-key]"
    echo "Run setup-ssh-key.sh first to generate an SSH key"
    exit 1
fi

if [ ! -f "${SSH_KEY_PATH}.pub" ]; then
    echo "Error: Public key not found at ${SSH_KEY_PATH}.pub"
    exit 1
fi

# Prompt for device name/title
read -p "Enter device name for GitHub (e.g., 'Linux Desktop', 'MacBook Pro'): " DEVICE_NAME

if [ -z "$DEVICE_NAME" ]; then
    echo "Error: Device name cannot be empty"
    exit 1
fi

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
    echo
    echo "GitHub CLI is not authenticated. Please authenticate first:"
    gh auth login
fi

# Check if a key with this title already exists
echo
echo "Checking for existing SSH key with title: $DEVICE_NAME"
EXISTING_KEY_ID=$(gh ssh-key list --json id,title --jq ".[] | select(.title == \"$DEVICE_NAME\") | .id" 2>/dev/null || true)

if [ -n "$EXISTING_KEY_ID" ]; then
    echo "Found existing SSH key with ID: $EXISTING_KEY_ID"
    read -p "Do you want to replace it? (y/n): " REPLACE

    if [[ "$REPLACE" =~ ^[Yy]$ ]]; then
        echo "Deleting existing SSH key..."
        gh ssh-key delete "$EXISTING_KEY_ID" --yes
        echo "✓ Existing key deleted"
    else
        echo "Aborting. Key not replaced."
        exit 0
    fi
fi

# Add SSH key to GitHub
echo
echo "Adding SSH key to GitHub with title: $DEVICE_NAME"
gh ssh-key add "${SSH_KEY_PATH}.pub" --title "$DEVICE_NAME"

# Test connection
echo
echo "Testing SSH connection to GitHub..."
if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    echo "✓ SSH key successfully configured!"
else
    echo "Connection test output:"
    ssh -T git@github.com 2>&1 || true
fi

echo
echo "=== Upload Complete ==="
echo "Public key: ${SSH_KEY_PATH}.pub"
echo "Device: $DEVICE_NAME"
