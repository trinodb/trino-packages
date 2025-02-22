# trino-packages

A repository for the creation of other binary packages of Trino, beyond the
default tarball and container images from the main [trino
repository](https://github.com/trinodb/trino) and documented on the [Trino
website](https://trino.io).

## RPM package

Setup for creating an RPM package of Trino, migrated from Trino 470 as archive
and potential usage for newer versions after the removal of the RPM from the
core Trino project.

Find more [information about building and using the RPM in the
documentation](trino-server-rpm/README.md).

## Custom tarball package

Setup for creating a custom `tar.gz` package of Trino built on top of the core
package available with Trino 472 and newer. The example includes configuration
files, a limited subset of Trino plugins, and instructions for your own
customizations.

Find more [information about building and using the custom tarball package in
the documentation](trino-server-custom/README.md).

## Potential future additions

The following other package ideas are suitable for implementation in this
repository.

* RPM suitable for different distributions
* Packages such as apk, deb, and others for other Linux distributions
* Homebrew or other special packages
* Example for custom tarball with startup and config scripts included
* Example for custom tarball with reduced plugin selection
* Example for custom docker container with subset of plugins
* Example for custom docker container with different base and other
  modifications
* Trino CLI only docker container

[Contributions welcome](.github/CONTRIBUTING.md)!