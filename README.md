<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
# Table of Contents

- [Backup the SSH Keys](#backup-the-gpgssh-keys)
- [Restore the SSH Keys](#restore-the-gpgssh-keys)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Backup the SSH Keys

Archive the private keys

```sh
tar zcvf private-keys.tgz id_ed25519
```

Encrypt the private-keys.tgz archive with a 'master' password

```sh
openssl aes-256-cbc -salt -pbkdf2 -in private-keys.tgz -out private-keys.tgz.enc
```

`private-keys.tgz.enc` can be made publicly available, as it is encrypted with
the master supplied password.

# Restore the SSH Keys

```sh
wget -P ~/.ssh https://github.com/duc-mt/ssh-keys/raw/refs/heads/master/private-keys.tgz.enc && openssl aes-256-cbc -salt -pbkdf2 -in ~/.ssh/private-keys.tgz.enc -out ~/.ssh/private-keys.tgz -d && tar zxvf ~/.ssh/private-keys.tgz -C ~/.ssh && rm ~/.ssh/private-keys.tgz*
```
