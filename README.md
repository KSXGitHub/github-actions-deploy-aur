# AUR publish docker action

This action can publish an AUR package.

## Inputs

### `package_name`

**Required** The AUR package name you want to update.

### `commit_username`

**Required** The username to use when creating the new commit.

### `commit_email`

**Required** The email to use when creating the new commit.

### `ssh_private_key`

**Required** Your private key with access to AUR package.



## Example usage

```
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
        uses: guumaster/aur-publish-docker-action@v1
        with:
          package_name: my-awesome-package
          commit_username: 'Github Action Bot'
          commit_email: github-action-bot@example.com
          ssh_private_key: ${{ secrets.AUR_SSH_PRIVATE_KEY }}
```
