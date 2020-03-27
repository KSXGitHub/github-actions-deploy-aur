# AUR publish docker action

This action can publish an AUR package.

## Inputs

### `package-name`

**Required** The AUR package name you want to update.

### `version`

**Required** version to publish.

### `commit-username`

**Required** The username to use when creating the new commit.

### `commit-email`

**Required** The email to use when creating the new commit.

### `ssh-private-key`

**Required** Your private key with access to AUR package.



## Example usage

```
uses: aur-publish-docker-action@v1
with:
  package-name: my-awesome-package
  version: {{ github.ref }}
  commit-username: 'Github Action Bot'
  commit-email: github-action-bot@example.com
  ssh-private-key: {{ secrets.aur-ssh-private-key }}
```
