#!/bin/bash

set -o errexit -o pipefail -o nounset

REPO_NAME=$1
NEW_RELEASE=${GITHUB_REF##*/v}
GIT_USERNAME=$2
GIT_EMAIL=$3
SSH_PRIVATE_KEY=$4


echo "---------------- AUR Package version $REPO_NAME/$NEW_RELEASE ----------------"

ssh-keyscan -t ed25519 aur.archlinux.org >> ~/.ssh/known_hosts

echo -e "${SSH_PRIVATE_KEY//_/\\n}" > ~/.ssh/aur

chmod 600 ~/.ssh/aur*

git config --global user.name "$GIT_USERNAME"
git config --global user.email "$GIT_EMAIL"

REPO_URL="ssh://aur@aur.archlinux.org/${REPO_NAME}.git"

echo "---------------- $REPO_URL ----------------"

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
git commit --allow-empty  -m "Update to $NEW_RELEASE"
git push

echo "------------- PUBLISH DONE ----------------"
