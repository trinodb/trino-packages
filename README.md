# trino-packages

A repository for the creation of other binary packages of Trino, beyond the
default tarball and container images from the main [trino
repository](https://github.com/trinodb/trino) and documented on the [Trino
website](https://trino.io).

## RPM package

Set up for creating an RPM package of Trino, migrated from Trino 470 as archive
and potential usage for newer versions after the removal of the RPM from the
core Trino project.

Find more [information about building and using the RPM in the
documentation](trino-server-rpm/README.md).

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