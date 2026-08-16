# frp-debian

[![Debian Build Bot](https://github.com/donmor-repos/frp-debian/actions/workflows/dpkg-buildpackage.yml/badge.svg?event=release)](https://github.com/donmor-repos/frp-debian/actions/workflows/dpkg-buildpackage.yml)

(Unofficial) Debian packaging scripts for [FRP project](https://github.com/fatedier/frp).

Provided packages:
- `frp` (meta)
- `frpc` (+dbgsym)
- `frpc-common`
- `frps` (+dbgsym)
- `frps-common`

## Quick configuration
Install [`donmor-repos-keyring`](https://donmor-repos.github.io/pub/donmor-repos-keyring_0.0.1_all.deb) and [`frp-debian-repo`](https://donmor-repos.github.io/pub/frp-debian-repo_0.0.1_all.deb), then run `apt-get update`.

## Manual configuration
#### Add keyring:
``` bash
curl -sLOJR --output-dir /usr/share/keyrings https://donmor-repos.github.io/pub/donmor-repos-keyring.gpg
```
#### Add `frp-debian`:
``` bash
# tee /etc/apt/sources.list.d/frp.sources <<EOF
Types: deb deb-src
URIs: https://github.com/donmor-repos/frp-debian/releases/latest/download
Suites: /
Signed-By: /usr/share/keyrings/donmor-repos-keyring.gpg
EOF
apt-get update
```
