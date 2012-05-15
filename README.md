# deb-npm-autopackage

A quick hack to make deb packages for npm modules.

Fetches node.js modules with npm, then makes a (somewhat messy)
deb package around it.

## Features

* Fetches code using npm
* Detects modules with binaries and sets the package arch accordingly
* Supports arbitrary versions
* Cleans up after itself

## Bugs

* Scares `lintian`

## Usage

$ ./deb-npm-autopackage.sh
Usage: ./deb-npm-autopackage.sh packagename [version]
$

## Examples

### sprintf
    $ ./deb-npm-autopackage.sh sprintf
    Building sprintf in /tmp/tmp.j62Pqnq1PW
    /tmp/tmp.j62Pqnq1PW ~/deb-npm-autopackage
    npm http GET https://registry.npmjs.org/sprintf
    npm http 304 https://registry.npmjs.org/sprintf
    sprintf@0.1.1 ./node_modules/sprintf
    [ output snipped ]
    $ ls *deb
    node-auto-sprintf_0.1.1_all.deb
    $ dpkg -I node-auto-sprintf_0.1.1_all.deb 
     new debian package, version 2.0.
     size 4564 bytes: control archive= 573 bytes.
         338 bytes,    10 lines      control              
         376 bytes,     5 lines      md5sums              
     Package: node-auto-sprintf
     Version: 0.1.1
     Architecture: all
     Maintainer: Metricfire deb-npm-autopackage <deb-npm-autopackage@example.com>
     Installed-Size: 68
     Depends: node
     Section: libs
     Priority: optional
     Description: Automatically generated package for the nodejs package sprintf
      sprintf - see http://search.npmjs.org/#/sprintf for more.

### sprintf with a specific version
    $ ./deb-npm-autopackage.sh sprintf 0.1.0
    [ output snipped ]
    ls *deb
    node-auto-sprintf_0.1.0_all.deb


