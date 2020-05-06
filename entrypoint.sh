#!/bin/bash

set -o errexit -o pipefail -o nounset

pkgname=$INPUT_PKGNAME
pkgbuild=$INPUT_PKGBUILD
commit_username=$INPUT_COMMIT_USERNAME
commit_email=$INPUT_COMMIT_EMAIL
ssh_private_key=$INPUT_SSH_PRIVATE_KEY
commit_message=$INPUT_COMMIT_MESSAGE
ssh_keyscan_types=$INPUT_SSH_KEYSCAN_TYPES

echo 'Initializing ssh directory...'
mkdir -pv ~/.ssh
touch ~/.ssh/known_hosts
cp -v /ssh_config ~/.ssh/config
chmod -v 600 ~/.ssh/*

echo 'Adding aur.archlinux.org to known hosts...'
ssh-keyscan -v -t "$ssh_keyscan_types" aur.archlinux.org >> ~/.ssh/known_hosts

echo 'Importing private key...'
echo "$ssh_private_key" > ~/.ssh/aur
chmod 600 ~/.ssh/aur*

echo 'Configuring git...'
git config --global user.name "$commit_username"
git config --global user.email "$commit_email"

echo "Cloning AUR package into /local-repo..."
git clone "https://aur.archlinux.org/{pkgname}.git" /local-repo

echo "Copying PKGBUILD from $pkgbuild to /local-repo"
cp -v "$pkgbuild" /local-repo/PKGBUILD

echo "Updating .SRCINFO"
makepkg --printsrcinfo > /local-repo/.SRCINFO

echo "Publishing..."
cd /local-repo
git remote add aur "ssh://aur@aur.archlinux.org/${pkgname}.git"
git add -fv PKGBUILD .SRCINFO
git commit --allow-empty -m "$commit_message"
git push -fv aur master
