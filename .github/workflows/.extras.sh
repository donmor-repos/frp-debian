#!/bin/sh

# Get info
node_req=`jq -r '.devDependencies."@types/node"' web/frpc/package.json`
NODE_VERSION=$node_req.x
go_req=`grep '^go [0-9.]\+$' go.mod | grep -o '[0-9.]\+' | awk -F. '{print $1"."$2"."($3+0)}'`
go_pkg=`curl -sL "https://go.dev/dl/?mode=json&include=all" | jq -r --arg major ${go_req} --arg arch ${GOHOSTARCH}  'first(.[] | select(.version | contains($major))) | .files[] | select(.os == "linux" and .arch == $arch) | .filename'`
C_ARCH=`echo ${C_ARCH} | sed 's/_/-/'`
cross_pkg=`echo gcc-${C_ARCH} g++-${C_ARCH} binutils-${C_ARCH} libc6-dev-${D_ARCH}-cross`
#cross_pkg=`[ ! "$GOARCH" = "$GOHOSTARCH" ] && echo gcc-${C_ARCH} g++-${C_ARCH} binutils-${C_ARCH} libc6-dev-${D_ARCH}-cross || echo ""`
#cross_pkg=`[ ! "$GOARCH" = "$GOHOSTARCH" ] && echo crossbuild-essential-${D_ARCH} libc6-dev-${D_ARCH}-cross || echo ""`
echo Required Node version: ${node_req}
echo Required Go version: ${go_req}
echo Required cross toolchain: ${cross_pkg}
# Get nodejs and npm
if ! curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /usr/share/keyrings/nodesource.gpg || ! chmod 644 /usr/share/keyrings/nodesource.gpg; then exit 1; fi
cat <<EOF | tee /etc/apt/sources.list.d/nodesource.sources > /dev/null
Types: deb
URIs: https://deb.nodesource.com/node_$NODE_VERSION
Suites: nodistro
Components: main
Architectures: $H_ARCH
Signed-By: /usr/share/keyrings/nodesource.gpg
EOF
echo "Package: nodejs" | tee /etc/apt/preferences.d/nodejs > /dev/null
echo "Pin: origin deb.nodesource.com" | tee -a /etc/apt/preferences.d/nodejs > /dev/null
echo "Pin-Priority: 600" | tee -a /etc/apt/preferences.d/nodejs > /dev/null
# Get go from Google
curl -L -o /tmp/go.tar.gz https://dl.google.com/go/${go_pkg}
mkdir -p /tmp/golang-go/DEBIAN /tmp/golang-go/usr/bin /tmp/golang-go/usr/lib
tar -xzf /tmp/go.tar.gz -C /tmp/golang-go/usr/lib
ln -sf ../lib/go/bin/go /tmp/golang-go/usr/bin/go
ln -sf ../lib/go/bin/gofmt /tmp/golang-go/usr/bin/gofmt
cat <<EOF | tee /tmp/golang-go/DEBIAN/control > /dev/null
Package: golang-go
Version: 2:$go_req~1
Architecture: $H_ARCH
Maintainer: donmor <donmor3000@hotmail.com>
Description: Go programming language compiler and tools
 This package provides the official Go binary distribution for Linux/amd64.
 It is a simple repackaging of the upstream tarball.
EOF
dpkg-deb --root-owner-group --build /tmp/golang-go /tmp/golang-go.deb
# Install packages
if ! apt-get update || ! apt-get install -y --no-install-recommends build-essential debhelper nodejs /tmp/golang-go.deb ${cross_pkg}; then exit 1; fi
echo 'Using node:\t'`which node`':\t'`node -v`
echo 'Using go:\t'`which go`':\t'`go version`
# End hack
