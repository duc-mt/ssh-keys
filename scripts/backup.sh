#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYS_DIR="$REPO_ROOT/keys"
TARGET_SSH_DIR="${HOME}/.ssh"

KEY_NAME="${1:-id_ed25519}"
KEY_PATH=""

if [ -f "$TARGET_SSH_DIR/$KEY_NAME" ]; then
    KEY_PATH="$TARGET_SSH_DIR/$KEY_NAME"
elif [ -f "$REPO_ROOT/$KEY_NAME" ]; then
    KEY_PATH="$REPO_ROOT/$KEY_NAME"
elif [ -f "$1" ]; then
    KEY_PATH="$1"
    KEY_NAME="$(basename "$1")"
else
    echo "Error: Private key '$KEY_NAME' not found in $TARGET_SSH_DIR or current directory."
    echo "Usage: $0 [key-name-or-path] (default: id_ed25519)"
    exit 1
fi

mkdir -p "$KEYS_DIR"

echo "1. Exporting public key..."
PUB_KEY_PATH="${KEY_PATH}.pub"
if [ -f "$PUB_KEY_PATH" ]; then
    cp "$PUB_KEY_PATH" "$KEYS_DIR/${KEY_NAME}.pub"
    echo "   Copied public key to keys/${KEY_NAME}.pub"
else
    echo "   Extracting public key from private key..."
    ssh-keygen -y -f "$KEY_PATH" > "$KEYS_DIR/${KEY_NAME}.pub"
fi

echo "2. Archiving private key..."
TEMP_ARCHIVE="$KEYS_DIR/private-keys.tgz"
tar -C "$(dirname "$KEY_PATH")" -zcvf "$TEMP_ARCHIVE" "$KEY_NAME"

echo "3. Encrypting archive (you will be prompted for a password)..."
openssl aes-256-cbc -salt -pbkdf2 -in "$TEMP_ARCHIVE" -out "$KEYS_DIR/private-keys.tgz.enc"

echo "4. Cleaning up unencrypted temporary archive..."
rm -f "$TEMP_ARCHIVE"

echo "------------------------------------------------------"
echo "✅ SSH Key Backup complete!"
echo "The following files are updated and ready to be committed:"
echo "  - keys/${KEY_NAME}.pub"
echo "  - keys/private-keys.tgz.enc"
