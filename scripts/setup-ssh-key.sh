#!/usr/bin/env bash

set -e

echo "=== SSH Key Setup for GitHub ==="
echo

# Prompt for device name
read -p "Enter device name (e.g., 'Linux Desktop', 'MacBook Pro'): " DEVICE_NAME

if [ -z "$DEVICE_NAME" ]; then
    echo "Error: Device name cannot be empty"
    exit 1
fi

# Convert device name to email-friendly format (lowercase, replace spaces with hyphens)
EMAIL_SUFFIX=$(echo "$DEVICE_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')
EMAIL="yohanes@$EMAIL_SUFFIX"

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

# Check if SSH key already exists
if [ -f "$SSH_KEY_PATH" ]; then
    echo
    echo "SSH key already exists at $SSH_KEY_PATH"
    read -p "Do you want to use the existing key? (y/n): " USE_EXISTING

    if [[ ! "$USE_EXISTING" =~ ^[Yy]$ ]]; then
        echo "Aborting. Please manually manage your SSH keys."
        exit 0
    fi
else
    # Generate new SSH key
    echo
    echo "Generating new SSH key with comment: $EMAIL"
    ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY_PATH"

    # Start ssh-agent and add key
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY_PATH"
fi

# Check if gh is authenticated
if ! gh auth status &>/dev/null; then
    echo
    echo "GitHub CLI is not authenticated. Please authenticate first:"
    gh auth login
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
echo "=== Setup Complete ==="
echo "Public key: ${SSH_KEY_PATH}.pub"
echo "Device: $DEVICE_NAME"
