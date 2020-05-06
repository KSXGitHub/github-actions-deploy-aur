#!/bin/bash

set -o errexit -o pipefail -o nounset

PKGNAME=$INPUT_PKGNAME
PKGVER=${INPUT_PKGVER}
COMMIT_USERNAME=$INPUT_COMMIT_USERNAME
COMMIT_EMAIL=$INPUT_COMMIT_EMAIL
SSH_PRIVATE_KEY=$INPUT_SSH_PRIVATE_KEY

echo "---------------- AUR Package version $PKGNAME/$PKGVER ----------------"

ssh-keyscan -t ed25519 aur.archlinux.org >> ~/.ssh/known_hosts

echo -e "${SSH_PRIVATE_KEY//_/\\n}" > ~/.ssh/aur

chmod 600 ~/.ssh/aur*

git config --global user.name "$COMMIT_USERNAME"
git config --global user.email "$COMMIT_EMAIL"

REPO_URL="ssh://aur@aur.archlinux.org/${PKGNAME}.git"

echo "---------------- $REPO_URL ----------------"

cd /tmp
git clone "$REPO_URL"
cd "$PKGNAME"

echo "------------- BUILDING PKG $PKGNAME ----------------"

sed -i "s/pkgver=.*$/pkgver=$PKGVER/" PKGBUILD
sed -i "s/sha256sums=.*$/$(makepkg -g 2>/dev/null)/" PKGBUILD

# Update srcinfo
makepkg --printsrcinfo > .SRCINFO

echo "------------- BUILD DONE ----------------"

# Update aur
git add --force PKGBUILD .SRCINFO
git commit --allow-empty  -m "Update to $PKGVER"
git push --force

echo "------------- PUBLISH DONE ----------------"
