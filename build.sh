#!/bin/bash
# shellcheck disable=SC2024

set -o errexit -o pipefail -o nounset

pkgname=$INPUT_PKGNAME
pkgbuild=$INPUT_PKGBUILD
assets=$INPUT_ASSETS
asset_dir=$INPUT_ASSET_DIR
updpkgsums=$INPUT_UPDPKGSUMS
test=$INPUT_TEST
read -r -a test_flags <<< "$INPUT_TEST_FLAGS"
post_process=$INPUT_POST_PROCESS
commit_username=$INPUT_COMMIT_USERNAME
commit_email=$INPUT_COMMIT_EMAIL
ssh_private_key=$INPUT_SSH_PRIVATE_KEY
commit_message=$INPUT_COMMIT_MESSAGE
allow_empty_commits=$INPUT_ALLOW_EMPTY_COMMITS
force_push=$INPUT_FORCE_PUSH
ssh_keyscan_types=$INPUT_SSH_KEYSCAN_TYPES

assert_non_empty() {
  name=$1
  value=$2
  if [[ -z "$value" ]]; then
    echo "::error::Invalid Value: $name is empty." >&2
    exit 1
  fi
}

assert_non_empty inputs.pkgname "$pkgname"
if [[ -n "$asset_dir" ]]; then
  # asset_dir is the full source of truth for the repository, so it is
  # mutually exclusive with both pkgbuild and assets.
  if [[ -n "$pkgbuild" ]]; then
    echo "::error::Invalid Value: inputs.asset_dir and inputs.pkgbuild are mutually exclusive." >&2
    exit 1
  fi
  if [[ -n "$assets" ]]; then
    echo "::error::Invalid Value: inputs.asset_dir and inputs.assets are mutually exclusive." >&2
    exit 1
  fi
  if [[ ! -d "$asset_dir" ]]; then
    echo "::error::Invalid Value: inputs.asset_dir ('$asset_dir') is not a directory." >&2
    exit 1
  fi
  if [[ ! -f "$asset_dir/PKGBUILD" ]]; then
    echo "::error::Invalid Value: inputs.asset_dir ('$asset_dir') does not contain a PKGBUILD." >&2
    exit 1
  fi
  # Resolve to an absolute path now, while we are still in the workspace, so the
  # later `cd /tmp/local-repo` does not change how a relative asset_dir resolves.
  asset_dir=$(realpath "$asset_dir")
else
  assert_non_empty inputs.pkgbuild "$pkgbuild"
fi
assert_non_empty inputs.commit_username "$commit_username"
assert_non_empty inputs.commit_email "$commit_email"
assert_non_empty inputs.ssh_private_key "$ssh_private_key"

export HOME=/home/builder

# Ignore "." and ".." to prevent errors when glob pattern for assets matches hidden files
GLOBIGNORE=".:.."

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

echo '::group::Configuring Git'
git config --global user.name "$commit_username"
git config --global user.email "$commit_email"
echo '::endgroup::'

echo '::group::Cloning AUR package into /tmp/local-repo'
git clone -v "https://aur.archlinux.org/${pkgname}.git" /tmp/local-repo
echo '::endgroup::'

echo '::group::Copying files into /tmp/local-repo'
if [[ -n "$asset_dir" ]]; then
  cd /tmp/local-repo
  # Mirror $asset_dir into the repo: first delete everything currently tracked
  # (so files removed from $asset_dir are also removed from the AUR repo), then
  # copy $asset_dir's contents back in. The .git directory is left untouched.
  if git rev-parse --verify --quiet HEAD >/dev/null; then
    echo 'Deleting tracked files'
    git ls-tree -r --name-only -z HEAD | xargs -0 -r rm -fv
  fi
  echo "Mirroring $asset_dir into /tmp/local-repo"
  # --filter=':- .gitignore' makes rsync honour any .gitignore files in $asset_dir.
  rsync -av --filter=':- .gitignore' --exclude=.git "${asset_dir%/}/" /tmp/local-repo/
else
  {
    echo "Copying $pkgbuild"
    cp -v "$pkgbuild" /tmp/local-repo/PKGBUILD
  }
  # shellcheck disable=SC2086
  # Ignore quote rule because we need to expand glob patterns to copy $assets
  if [[ -n "$assets" ]]; then
    echo 'Copying' $assets
    cp -rvt /tmp/local-repo/ $assets
  fi
fi
echo '::endgroup::'

if [ "$updpkgsums" == "true" ]; then
	echo '::group::Updating checksums'
	cd /tmp/local-repo/
	updpkgsums
	echo '::endgroup::'
fi

if [ "$test" == "true" ]; then
	echo '::group::Building package with makepkg'
	cd /tmp/local-repo/
	makepkg "${test_flags[@]}"
	echo '::endgroup::'
fi

echo '::group::Generating .SRCINFO'
cd /tmp/local-repo
makepkg --printsrcinfo >.SRCINFO
echo '::endgroup::'

if [ -n "$post_process" ]; then
	echo '::group::Executing post process commands'
	cd /tmp/local-repo/
  eval "$post_process"
	echo '::endgroup::'
fi

echo '::group::Committing files to the repository'
if [[ -z "$assets" && -z "$asset_dir" ]]; then
  # When neither $assets nor $asset_dir are set, we can add just PKGBUILD and .SRCINFO
  # This is to prevent unintended behaviour and maintain backwards compatibility
  git add -fv PKGBUILD .SRCINFO
else
  # We cannot just re-use $assets because it contains absolute paths outside repository.
  # For $asset_dir we also need to stage deletions of files removed from the mirror.
  # In both cases `git add --all` stages every change in the repository.
  git add --all
fi

case "$allow_empty_commits" in
true)
  git commit --allow-empty -m "$commit_message"
  ;;
false)
  git diff-index --quiet HEAD || git commit -m "$commit_message" # use `git diff-index --quiet HEAD ||` to avoid error
  ;;
*)
  echo "::error::Invalid Value: inputs.allow_empty_commits is neither 'true' nor 'false': '$allow_empty_commits'"
  exit 2
  ;;
esac
echo '::endgroup::'

echo '::group::Publishing the repository'
git remote add aur "ssh://aur@aur.archlinux.org/${pkgname}.git"
case "$force_push" in
true)
  git push -v --force aur master
  ;;
false)
  git push -v aur master
  ;;
*)
  echo "::error::Invalid Value: inputs.force_push is neither 'true' nor 'false': '$force_push'"
  exit 3
  ;;
esac
echo '::endgroup::'
