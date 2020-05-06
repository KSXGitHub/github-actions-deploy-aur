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
ssh_agent=$(eval "$(ssh-agent -s)" | awk '{ print $3 }')
ssh-add -v ~/.ssh/*

echo 'Configuring git...'
git config --global user.name "$commit_username"
git config --global user.email "$commit_email"

repo_url="ssh://aur@aur.archlinux.org/${pkgname}.git"

echo "Cloning $repo_url into /local-repo..."
git clone "$repo_url" /local-repo

echo "Copying PKGBUILD from $pkgbuild to /local-repo"
cp -v "$pkgbuild" /local-repo/PKGBUILD

echo "Updating .SRCINFO"
makepkg --printsrcinfo > /local-repo/.SRCINFO

echo "Publishing..."
cd /local-repo
git add -fv PKGBUILD .SRCINFO
git commit --allow-empty -m "$commit_message"
git push -fv origin master
