#!/usr/bin/env bash

set -e

# Ensure we have access to system binaries
export PATH="/usr/bin:/usr/sbin:$PATH"

echo "=== SSH Key Setup ==="
echo

# Try to get email from git config, otherwise prompt
DEFAULT_EMAIL=$(git config --global user.email 2>/dev/null || true)

if [ -n "$DEFAULT_EMAIL" ]; then
    echo "Found git email: $DEFAULT_EMAIL"
    read -p "Use this email? [Y/n]: " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        read -p "Enter email for SSH key: " EMAIL
    else
        EMAIL="$DEFAULT_EMAIL"
    fi
else
    read -p "Enter email for SSH key comment (e.g., 'yohanes@linux-desktop'): " EMAIL
fi

if [ -z "$EMAIL" ]; then
    echo "Error: Email cannot be empty"
    exit 1
fi

SSH_KEY_PATH="$HOME/.ssh/id_ed25519"

# Check if SSH key already exists
if [ -f "$SSH_KEY_PATH" ]; then
    echo
    echo "SSH key already exists at $SSH_KEY_PATH"
    read -p "Do you want to overwrite it? (y/n): " OVERWRITE

    if [[ ! "$OVERWRITE" =~ ^[Yy]$ ]]; then
        echo "Aborting. Existing key preserved."
        exit 0
    fi
fi

# Generate new SSH key
echo
echo "Generating new SSH key with comment: $EMAIL"
ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY_PATH"

# Start ssh-agent and add key
echo
echo "Starting SSH agent and adding key..."
eval "$(ssh-agent -s)"
ssh-add "$SSH_KEY_PATH"

echo
echo "=== Setup Complete ==="
echo "Public key: ${SSH_KEY_PATH}.pub"
echo "Private key: $SSH_KEY_PATH"
echo
echo "To upload this key to GitHub, run:"
echo "  ./upload-ssh-to-github.sh"
