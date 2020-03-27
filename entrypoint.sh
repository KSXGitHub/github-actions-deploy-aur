#!/bin/bash

set -o errexit -o pipefail -o nounset

PACKAGE_NAME=$INPUT_PACKAGE_NAME
COMMIT_USERNAME=$INPUT_COMMIT_USERNAME
COMMIT_EMAIL=$INPUT_COMMIT_EMAIL
SSH_PRIVATE_KEY=$INPUT_SSH_PRIVATE_KEY

NEW_RELEASE=${GITHUB_REF##*/v}

export HOME=/home/builder

echo "---------------- AUR Package version $PACKAGE_NAME/$NEW_RELEASE ----------------"

ssh-keyscan -t ed25519 aur.archlinux.org >> $HOME/.ssh/known_hosts

echo -e "${SSH_PRIVATE_KEY//_/\\n}" > $HOME/.ssh/aur

chmod 600 $HOME/.ssh/aur*

git config --global user.name "$COMMIT_USERNAME"
git config --global user.email "$COMMIT_EMAIL"

REPO_URL="ssh://aur@aur.archlinux.org/${PACKAGE_NAME}.git"

echo "---------------- $REPO_URL ----------------"

git clone "$REPO_URL"
cd "$PACKAGE_NAME"

echo "------------- BUILDING PKG $PACKAGE_NAME ----------------"

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
