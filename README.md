# AUR publish docker action

This action can publish an AUR package.


## Requirements

It depends on an environment variable called `GITHUB_REF` to be present and it should also contain a semantic version
in the format `v0.0.0` to work properly.

This tag should also comply with rules established to publish versions on AUR repository.

You should add to your secrets an SSH private key that match your key uploaded to your AUR account,
so this action can commit and push to it.


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
