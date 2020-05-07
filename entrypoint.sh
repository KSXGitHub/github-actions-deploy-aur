#!/bin/bash

set -o errexit -o pipefail -o nounset

pkgbuild=$INPUT_PKGBUILD

echo 'Creating builder user...'
useradd --create-home --shell /bin/bash builder
passwd --delete builder

echo 'Initializing ssh directory...'
mkdir -pv /home/builder/.ssh
touch /home/builder/.ssh/known_hosts
cp -v /ssh_config /home/builder/.ssh/config
chown -vR builder:builder /home/builder
chmod -vR 600 /home/builder/.ssh/*

echo 'Copying PKGBUILD...'
cp -r "$pkgbuild" /PKGBUILD

echo 'Running build.sh...'
exec runuser builder --command 'bash -l -c /build.sh'
