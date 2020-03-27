#!/bin/bash

set -o errexit -o pipefail -o nounset

REPO_NAME=$1
NEW_RELEASE=$2
GIT_USERNAME=$3
GIT_EMAIL=$4
SSH_PRIVATE_KEY=$5

ssh-keyscan -t ed25519 aur.archlinux.org >> ~/.ssh/known_hosts

echo -e "${SSH_PRIVATE_KEY//_/\\n}" > ~/.ssh/aur

chmod 600 ~/.ssh/aur*

sed -i "s/name = .*$/name = $GIT_USERNAME/" ~/.gitconfig
sed -i "s/email = .*$/email = $GIT_EMAIL/" ~/.gitconfig

REPO_URL="ssh://aur@aur.archlinux.org/${REPO_NAME}.git"

echo "------------- CLONNING $REPO_URL ----------------"

git clone $REPO_URL
cd $REPO_NAME

echo "------------- BUILDING PKG $REPO_NAME ----------------"

sed -i "s/pkgver=.*$/pkgver=$NEW_RELEASE/" PKGBUILD
sed -i "s/sha256sums=.*$/$(makepkg -g 2>/dev/null)/" PKGBUILD

# Test build
makepkg -c

# Update srcinfo
makepkg --printsrcinfo > .SRCINFO


echo "------------- BUILD DONE ----------------"

# Update aur
git add PKGBUILD .SRCINFO
git commit -m "Update to $NEW_RELEASE"

