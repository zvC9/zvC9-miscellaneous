#!/bin/bash -x

KEY_SIG="0011223344556677"

mount -i -t ecryptfs ~/.private ~/private -o ecryptfs_sig=${KEY_SIG},ecryptfs_fnek_sig=${KEY_SIG},ecryptfs_cipher=aes,ecryptfs_key_bytes=32,ecryptfs_unlink_sigs


