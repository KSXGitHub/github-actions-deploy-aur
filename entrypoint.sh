#!/bin/bash

set -o errexit -o pipefail -o nounset

pkgname=$INPUT_PKGNAME
pkgbuild=$INPUT_PKGBUILD
commit_username=$INPUT_COMMIT_USERNAME
commit_email=$INPUT_COMMIT_EMAIL
ssh_private_key=$INPUT_SSH_PRIVATE_KEY
commit_message=$INPUT_COMMIT_MESSAGE

ssh-keyscan -t ed25519 aur.archlinux.org >> ~/.ssh/known_hosts

echo -e "${ssh_private_key//_/\\n}" > ~/.ssh/aur

chmod 600 ~/.ssh/aur*

git config --global user.name "$commit_username"
git config --global user.email "$commit_email"

repo_url="ssh://aur@aur.archlinux.org/${pkgname}.git"

git clone "$repo_url" /local-repo

echo "Copying PKGBUILD from $pkgbuild to /local-repo"
cp -v "$pkgbuild" /local-repo/PKGBUILD

echo "Updating .SRCINFO"
makepkg --printsrcinfo > /local-repo/.SRCINFO

git add -fv PKGBUILD .SRCINFO
git commit --allow-empty -m "$commit_message"
git push -fv
