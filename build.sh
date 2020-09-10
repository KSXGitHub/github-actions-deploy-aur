#!/bin/bash
# shellcheck disable=SC2024

set -o errexit -o pipefail -o nounset

pkgname=$INPUT_PKGNAME
commit_username=$INPUT_COMMIT_USERNAME
commit_email=$INPUT_COMMIT_EMAIL
ssh_private_key=$INPUT_SSH_PRIVATE_KEY
commit_message=$INPUT_COMMIT_MESSAGE
allow_empty_commits=$INPUT_ALLOW_EMPTY_COMMITS
ssh_keyscan_types=$INPUT_SSH_KEYSCAN_TYPES

export HOME=/home/builder

echo '::group::Adding aur.archlinux.org to known hosts'
ssh-keyscan -v -t "$ssh_keyscan_types" aur.archlinux.org >>~/.ssh/known_hosts
echo '::endgroup::'

echo '::group::Importing private key'
echo "$ssh_private_key" >~/.ssh/aur
chmod -vR 600 ~/.ssh/aur*
ssh-keygen -vy -f ~/.ssh/aur >~/.ssh/aur.pub
echo '::endgroup::'

echo '::group::Checksums of SSH keys'
sha512sum ~/.ssh/aur ~/.ssh/aur.pub
echo '::endgroup::'

echo '::group::Configuring git'
git config --global user.name "$commit_username"
git config --global user.email "$commit_email"
echo '::endgroup::'

echo '::group::Cloning AUR package into /tmp/local-repo'
git clone -v "https://aur.archlinux.org/${pkgname}.git" /tmp/local-repo
echo '::endgroup::'

echo '::group::Generating PKGBUILD and .SRCINFO'
cd /tmp/local-repo

echo 'Copying PKGBUILD...'
cp -v /PKGBUILD ./

echo "Updating .SRCINFO"
makepkg --printsrcinfo >.SRCINFO

echo '::endgroup::'

echo '::group::Publishing'
git remote add aur "ssh://aur@aur.archlinux.org/${pkgname}.git"
git add -fv PKGBUILD .SRCINFO
case "$allow_empty_commits" in
true) git commit --allow-empty -m "$commit_message" ;;
false) git diff-index --quiet HEAD || git commit -m "$commit_message" ;; # use `git diff-index --quiet HEAD ||` to avoid error
*) echo 'The option "allow_empty_commits" should be either "true" or "false".' && false ;;
esac
git push --force-with-lease -v aur master
echo '::endgroup::'
