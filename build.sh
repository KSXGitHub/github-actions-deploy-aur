#!/bin/bash
# shellcheck disable=SC2024

set -o errexit -o pipefail -o nounset

pkgname=$INPUT_PKGNAME
commit_username=$INPUT_COMMIT_USERNAME
commit_email=$INPUT_COMMIT_EMAIL
ssh_private_key=$INPUT_SSH_PRIVATE_KEY
commit_message=$INPUT_COMMIT_MESSAGE
ssh_keyscan_types=$INPUT_SSH_KEYSCAN_TYPES

export HOME=/home/builder

echo 'Adding aur.archlinux.org to known hosts...'
ssh-keyscan -v -t "$ssh_keyscan_types" aur.archlinux.org >> ~/.ssh/known_hosts

echo 'Importing private key...'
echo "$ssh_private_key" > ~/.ssh/aur
chmod -vR 600 ~/.ssh/aur*
ssh-keygen -vy -f ~/.ssh/aur > ~/.ssh/aur.pub

echo 'Checksums of SSH keys...'
sha512sum ~/.ssh/aur ~/.ssh/aur.pub

echo 'Configuring git...'
git config --global user.name "$commit_username"
git config --global user.email "$commit_email"

echo 'Cloning AUR package into /tmp/local-repo...'
git clone -v "https://aur.archlinux.org/${pkgname}.git" /tmp/local-repo
cd /tmp/local-repo

echo 'Copying PKGBUILD...'
cp -v /PKGBUILD ./

echo "Updating .SRCINFO"
makepkg --printsrcinfo > .SRCINFO

echo "Publishing..."
git remote add aur "ssh://aur@aur.archlinux.org/${pkgname}.git"
git add -fv PKGBUILD .SRCINFO
git commit --allow-empty -m "$commit_message"
git push -fv aur master
