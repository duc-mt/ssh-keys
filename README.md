# SSH Keys Backup

[![CI](https://github.com/duc-mt/ssh-keys/actions/workflows/ci.yml/badge.svg)](https://github.com/duc-mt/ssh-keys/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
# Table of Contents

- [Backup the SSH Keys](#backup-the-ssh-keys)
- [Restore the SSH Keys](#restore-the-ssh-keys)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Backup the SSH Keys

You can use the provided `scripts/backup.sh` script to automate the export, archive, and encryption of your SSH keys:

```sh
./scripts/backup.sh [key-name-or-path]
```
*(Default key name is `id_ed25519` if omitted)*

This will archive your private key, encrypt it with AES-256 (`openssl aes-256-cbc -salt -pbkdf2`), copy the public key to `keys/`, and remove any unencrypted temporary files:

- `keys/id_ed25519.pub`
- `keys/private-keys.tgz.enc`

`private-keys.tgz.enc` can be safely pushed to GitHub, as it is encrypted with your master password.

# Restore the SSH Keys

If you have cloned this repository locally, you can easily restore your keys using the automated script:

```sh
./scripts/restore.sh
```

The script will prompt for your master password, decrypt the archive, restore keys into `~/.ssh/`, and automatically enforce strict OpenSSH security permissions (`chmod 700 ~/.ssh` and `chmod 600 ~/.ssh/id_*`).

*(Alternatively, if you are downloading just the encrypted archive remotely without cloning the repo)*:

```sh
wget -P ~/.ssh https://github.com/duc-mt/ssh-keys/raw/refs/heads/master/keys/private-keys.tgz.enc && openssl aes-256-cbc -salt -pbkdf2 -in ~/.ssh/private-keys.tgz.enc -out ~/.ssh/private-keys.tgz -d && tar zxvf ~/.ssh/private-keys.tgz -C ~/.ssh && rm ~/.ssh/private-keys.tgz* && chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_* 2>/dev/null || true
```
