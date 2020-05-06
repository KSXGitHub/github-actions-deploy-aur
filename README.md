# Publish AUR packages

GitHub Actions to publish AUR package.

## Inputs

### `pkgname`

**Required** AUR package name.

### `pkgbuild`

**Required** Path to PKGBUILD file.

### `commit_username`

**Required** The username to use when creating the new commit.

### `commit_email`

**Required** The email to use when creating the new commit.

### `ssh_private_key`

**Required** Your private key with access to AUR package.

### `commit_message`

**Optional** Commit message to use when creating the new commit.

## Example usage

```yaml
name: aur-publish

on:
  push:
    tags:
      - '*'

jobs:
  aur-publish:
    runs-on: ubuntu-latest
    steps:
      - name: Publish AUR package
        uses: KSXGitHub/github-actions-deploy-aur@master
        with:
          pkgname: my-awesome-package
          pkgbuild: ./PKGBUILD
          commit_username: 'Github Action Bot'
          commit_email: github-action-bot@example.com
          ssh_private_key: ${{ secrets.AUR_SSH_PRIVATE_KEY }}
          commit_message: Update AUR package
```
