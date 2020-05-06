#!/bin/bash

set -o errexit -o pipefail -o nounset

pkgname=$INPUT_PKGNAME
pkgbuild=$INPUT_PKGBUILD
commit_username=$INPUT_COMMIT_USERNAME
commit_email=$INPUT_COMMIT_EMAIL
ssh_private_key=$INPUT_SSH_PRIVATE_KEY
commit_message=$INPUT_COMMIT_MESSAGE

echo 'Adding aur.archlinux.org to known hosts...'
ssh-keyscan -t ed25519 aur.archlinux.org >> ~/.ssh/known_hosts

echo 'Importing private key...'
echo "$ssh_private_key" > ~/.ssh/aur
chmod 600 ~/.ssh/aur*

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
git push -fv
