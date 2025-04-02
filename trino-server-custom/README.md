# Trino server custom tarball

This project is an example setup for creating a custom `tar.gz` package of
Trino built on top of the core package available with Trino 472 and newer. The
example includes configuration files, a limited subset of Trino plugins, and
instructions for your own customizations.

Use it as a base to create your own custom tarballs suitable for your needs with
different deployment use cases and clusters.

The following sections contain information for building, using, and customizing
the tarball.

## General information

Users can install Trino using the tarball on any Linux system. For development
and testing purposed MacOS is also supported.

The Trino project provides a `trino-server-core` tarball with the minimal
plugins and a default `trino-server` tarball with all available plugins. Both
tarballs do not contain any configuration files, and require further
customizations after extracting the tarball to create an installation that can
be started and run.

Instructions for this process are available in the [Trino
documentation](https://trino.io/docs/current/installation/deployment.html)

This project uses the core tarball and adds necessary configuration files and a
limited subset of plugins to create a tarball with the following
characteristics:

* Catalog `abyss` using the Blackhole connector.
* Catalog `brain` using the Memory connectors, configured for UDF storage in the
  `default` schema, and `brain.default` is added to the SQL path.
* Catalog `generator` using the Faker connector.
* Catalog `llm` using the AI functions plugin, the `llm.ai` schema location is
  added to the SQL path so AI functions can be invoked by name alone. Requires a
  locally running Ollama.
* Catalog `monitor` using the JMX connector.
* Catalog `tpch` using the TPC-H connector.
* Catalog `tpcds` using the TPC-DS connector.
* Memory configured to `4GB` set in `jvm.config` suitable for local testing on a
  small workstation.
* Node configured to act as coordinator and worker to allow single node use.
* Environment name set to `custom` in `node.properties`.
* No additional logging configured in `log.properties`.
* Preview Web UI enabled.
* Launcher script for PPC architecture removed.
* `ml` functions plugin from `trino-server-core` removed.
* `geospatial` functions plugin from `trino-server-core` removed.

The project is configured for Trino 474.

## Building

The build requirements for the project are identical to Trino build
requirements:

* Linux or MacOS
* Java 23

Download and extract or clone the repository to work with the `trino-packages`
directory locally on your machine.

Run a build with Maven:

```shell
cd trino-packages
./mvnw clean install
```

The project downloads the core tarball of the configured Trino release, adds
configurations files from `src/main/resources` and a limited number of plugins
configured in `src/main/provisio/trino-custom.xml`, and repackages it into a new
tarball package.

After a successful build, you find the tarball in the
`trino-packages/trino-server-custom/target` directory with the name
`trino-server-custom-472.tar.gz`. The specific version depends on the property
`dep.trino.version` configured in `trino-packages/trino-server-custom/pom.xml`.

## Installation

Build the project on any machine, and copy the tarball package from the
`trino-server-custom/target` directory to the server on which you want to
install Trino. The server must meet the Trino requirements for the specific
Trino version, for example Java 23 for Trino 472.

Find details in the [Trino documentation](https://trino.io/docs/current/installation/deployment.html)

Extract the  `tar.gz` package to install Trino:

```shell
tar xfvz trino-server-custom-472.tar.gz
```

You can run Trino from the resulting directory for testing:

```shell
cd trino-server-custom-472
./bin/launcher run
```

Stop the server by interrupting the script with `CTRL-C`.

Use the launcher script also for [running in the background and other
operations](https://trino.io/docs/current/installation/deployment.html#running-trino).

Connect with the Trino CLI or any other client to explore catalogs and schemas,
and run your SQL queries.

## Customization

The project setup is an example and can be customized to suit your needs with
some of the following steps:

* Customize your configuration by modifying the files in `src/main/resources`.
* Add further configuration files in `src/main/resources`.
* Add catalogs by adding catalog properties files in
  `src/main/resources/etc/catalog` and uncommenting the relevant connector
  plugins in `src/main/provisio/trino-custom.xml`.
* Remove any unwanted configurations and catalogs in `src/main/resources`. 
* Remove any unwanted plugins by commenting the artifactSet out
  `src/main/provisio/trino-custom.xml`.
* Add custom plugins as extracted directories of JAR files in
  `src/main/resources/plugin` or define them as artifactSet in
  `src/main/provisio/trino-custom.xml` to download them from your local Maven
  repository, a repository manager, or the Maven Central Repository.

Use multiple copies of the project to create different tarballs for coordinator
and worker nodes and for different Trino clusters.

Refer to the [plugin
documentation](https://trino.io/docs/current/installation/plugins.html) and
other Trino documentation for more details.

## Updating to other Trino version

The project is configured to build a custom tarball for Trino 472. Updates to
newer versions can be contributed to the repository or can be done locally. The
following steps are necessary:

* Update the property `dep.trino.version` in 
  `trino-packages/trino-server-custom/pom.xml` to the desired Trino version.
* If necessary, adjust the included configuration files in `src/main/resources`.
* Add any newly available plugins in 
* Update the documentation in this `README.md` file.
