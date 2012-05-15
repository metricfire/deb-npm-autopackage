#!/bin/bash

package=$1
ver=$2

if [ -z "$package" ]
then
   echo "Usage: $0 packagename [version]"
   exit 1
fi

if [ -z "$NPM" ]
then
   NPM=$(which npm)
fi

if [ ! -x "$NPM" ]
then
   echo "Failed to find npm, the nodejs package manager."
fi

tmpdir=$(mktemp -d)

echo "Building $package in $tmpdir"

pushd $tmpdir

packagename=node-auto-$package

# Fetch package code and do whatever else npm wants to do
if [ ! -z "$ver" ]
then
   ver="@$ver"
fi

npm install $package$ver

pushd node_modules

version=$(python -c "import json, sys; print json.load(sys.stdin)['version']" < $package/package.json)

basedir=/usr/local/lib/node/

# Look for any executables in the module. If we don't find any any, mark the
# package as suitable for all architectures. Otherwise, only this architecture.
if [ -z "$(find $package -type f | xargs file | grep ELF)" ]
then
   export arch=all
else
   export arch=$(uname -i)
fi

# Make a bunch of package metadata files
mkdir debian

cat > debian/control <<EOF
Source: $packagename
Section: libs
Priority: optional
Maintainer: Metricfire deb-npm-autopackage <deb-npm-autopackage@example.com>
Standards-Version: 3.9.1

Package: $packagename
Architecture: $arch
Depends:
   node
Description: Automatically generated package for the nodejs package $package
 $package - see http://search.npmjs.org/#/$package for more.
EOF

cat > debian/changelog <<EOF
$packagename ($version) unstable; urgency=low

  * Automatically generated package.

 -- Metricfire deb-npm-autopackage <deb-npm-autopackage@example.com>  $(date +"%a, %d %b %Y %T %z")
EOF

echo 6 > debian/compat

cat > debian/copyright <<EOF
Name: $packagename
Copyright: unknown
EOF

cat > debian/rules <<EOF
#!/usr/bin/make -f
# -*- makefile -*-

# Uncomment this to turn on verbose mode.
#export DH_VERBOSE=1
#export DH_OPTIONS=-v

%:
	echo "target" \$@
	dh \$@

# dh_usrlocal disabled because we need to install into /usr/local because node has terrible manners.
override_dh_usrlocal:
EOF

find $package -type d -printf "$basedir%p\n" > debian/dirs
find $package -type f -printf "%p $basedir%h/\n" > debian/install

# Build the package.
dpkg-buildpackage

# Copy package out
debpath=$(readlink -f ../*deb)
debname=$(basename $debpath)
popd
popd
cp $debpath .

rm -rf $tmpdir

