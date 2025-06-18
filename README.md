# trino-packages

A repository for the creation of other binary packages of Trino, beyond the
default tarball and container images from the main [trino
repository](https://github.com/trinodb/trino) and documented on the [Trino
website](https://trino.io), specifically the [installation
documentation](https://trino.io/docs/current/installation.html)

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

## Build

You can build the project with the modules `trino-server-custom` and
`trino-server-rpm` with the following commands:

```shell
cd trino-packages
./mvnw clean install
```

Including all tests:

```shell
./mvnw -P ci clean install
```

More details in the specific module
[trino-server-custom](trino-server-custom/README.md) and the
[trino-server-rpm](trino-server-rpm/README.md) README files.

Building the custom Docker image is separate and documented in the
[custom-docker](custom-docker/README.md) README file.

## Potential future additions

The following other package ideas are suitable for implementation in this
repository.

* RPM suitable for different distributions
* Packages such as apk, deb, and others for other Linux distributions
* Homebrew or other special packages
* Docker image with Trino CLI only

[Contributions welcome](.github/CONTRIBUTING.md)!
