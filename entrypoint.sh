#!/bin/bash

set -o errexit -o pipefail -o nounset

PKGNAME=$INPUT_PKGNAME
PKGVER=${INPUT_PKGVER}
COMMIT_USERNAME=$INPUT_COMMIT_USERNAME
COMMIT_EMAIL=$INPUT_COMMIT_EMAIL
SSH_PRIVATE_KEY=$INPUT_SSH_PRIVATE_KEY

export HOME=/home/builder

echo "---------------- AUR Package version $PKGNAME/$PKGVER ----------------"

ssh-keyscan -t ed25519 aur.archlinux.org >> $HOME/.ssh/known_hosts

echo -e "${SSH_PRIVATE_KEY//_/\\n}" > $HOME/.ssh/aur

chmod 600 $HOME/.ssh/aur* || exit $?

git config --global user.name "$COMMIT_USERNAME"
git config --global user.email "$COMMIT_EMAIL"

REPO_URL="ssh://aur@aur.archlinux.org/${PKGNAME}.git"

echo "---------------- $REPO_URL ----------------"

cd /tmp
git clone "$REPO_URL" || exit $?
cd "$PKGNAME" || exit $?

echo "------------- BUILDING PKG $PKGNAME ----------------"

sed -i "s/pkgver=.*$/pkgver=$PKGVER/" PKGBUILD
sed -i "s/sha256sums=.*$/$(makepkg -g 2>/dev/null)/" PKGBUILD

# Test build
makepkg -c || exit $?

# Update srcinfo
makepkg --printsrcinfo > .SRCINFO || exit $?


echo "------------- BUILD DONE ----------------"

# Update aur
git add PKGBUILD .SRCINFO || exit $?
git commit --allow-empty  -m "Update to $PKGVER" || exit $?
git push --force || exit $?

echo "------------- PUBLISH DONE ----------------"
