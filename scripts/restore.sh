#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYS_DIR="$REPO_ROOT/keys"
TARGET_SSH_DIR="${HOME}/.ssh"

ENCRYPTED_FILE="$KEYS_DIR/private-keys.tgz.enc"

if [ ! -f "$ENCRYPTED_FILE" ]; then
    echo "Error: Encrypted archive not found at $ENCRYPTED_FILE"
    exit 1
fi

mkdir -p "$TARGET_SSH_DIR"
chmod 700 "$TARGET_SSH_DIR"

TEMP_ARCHIVE="$TARGET_SSH_DIR/private-keys.tgz"

echo "1. Decrypting archive (you will be prompted for the master password)..."
openssl aes-256-cbc -salt -pbkdf2 -in "$ENCRYPTED_FILE" -out "$TEMP_ARCHIVE" -d

echo "2. Extracting private keys to $TARGET_SSH_DIR..."
tar -zxvf "$TEMP_ARCHIVE" -C "$TARGET_SSH_DIR"

echo "3. Copying public keys..."
for pub_file in "$KEYS_DIR"/*.pub; do
    if [ -f "$pub_file" ]; then
        cp "$pub_file" "$TARGET_SSH_DIR/"
    fi
done

echo "4. Setting secure file permissions..."
chmod 700 "$TARGET_SSH_DIR"
for priv in "$TARGET_SSH_DIR"/id_*; do
    if [ -f "$priv" ] && [[ "$priv" != *.pub ]]; then
        chmod 600 "$priv"
        echo "   Set chmod 600 for $priv"
    fi
done

for pub in "$TARGET_SSH_DIR"/*.pub; do
    if [ -f "$pub" ]; then
        chmod 644 "$pub"
    fi
done

echo "5. Cleaning up temporary files..."
rm -f "$TEMP_ARCHIVE"

echo "------------------------------------------------------"
echo "✅ SSH Key Restore complete!"
echo "Keys successfully restored and secured in $TARGET_SSH_DIR"
