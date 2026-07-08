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

## Custom container image

Setup for creating a custom container (Docker) image of Trino built on top of
the `trinodb/trino-core` image available with Trino 472 and newer. The example
includes configuration files, a limited subset of Trino plugins, and
instructions for your own customizations. The resulting image is suitable for
deployment to Kubernetes with the [Trino Helm
charts](https://github.com/trinodb/charts), as well as direct use with Docker
and Docker compose.

Find more [information about building and using the custom container image in
the documentation](custom-docker/README.md).

## Supported Trino versions

The packages in this repository are built and released against specific Trino
versions, available as [tags in this
repository](https://github.com/trinodb/trino-packages/tags):

* [482](https://github.com/trinodb/trino-packages/releases/tag/482)
* [481](https://github.com/trinodb/trino-packages/releases/tag/481)
* [475](https://github.com/trinodb/trino-packages/releases/tag/475)
* [474](https://github.com/trinodb/trino-packages/releases/tag/474)

Other Trino versions can be used by updating the version references as
documented in the README for each package: [RPM](trino-server-rpm/README.md),
[custom tarball](trino-server-custom/README.md), and [custom container
image](custom-docker/README.md). For best results, start from the nearest
lower tagged version relative to the Trino version you want to use.

An AI assistant skill that automates these version updates is available as the
[trino-packages-update skill](https://github.com/simpligility/getting-stuff-done/tree/main/skills/trino-packages-update).

## Potential future additions

The following other package ideas are suitable for implementation in this
repository.

* RPM suitable for different distributions
* Packages such as apk, deb, and others for other Linux distributions
* Homebrew or other special packages
* Docker image with Trino CLI only

[Contributions welcome](.github/CONTRIBUTING.md)!
