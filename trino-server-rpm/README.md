# Trino RPM package

Up to Trino version 470, RPM archives were published with each release of Trino.
These archives remain available on the [Maven Central
Repository](https://central.sonatype.com/artifact/io.trino/trino-server-rpm/versions).

This project is a migration of the codebase to create a separate project, 
because  the community no longer requires an RPM, and use of the tarball and 
container image is preferred. Users who still need an RPM archive can use this
repository to create their own RPM for newer versions of Trino and collaborate 
with the Trino community to maintain and potentially improve the package.

The following sections contain information for building and using the RPM.

## General information

Users can install Trino using the RPM Package Manager (RPM) on some Linux
distributions that support RPM.

The RPM archive contains the application, all plugins, the necessary default
configuration files, default setups, and integration with the operating system
to start as a service.

The project is configured for Trino 474.

## Building

The build requirements for the project are identical to Trino build requirements:

* Linux or MacOS
* Java 23

Download and extract or clone the repository to work with the `trino-packages`
directory locally on your machine.

Run a build with Maven:

```shell
cd trino-packages
./mvnw clean install
```

The project downloads the tarball of the configured Trino release, adds scripts
and configurations, and repackages it into an RPM archive.

After a successful build, you find the RPM in the
`trino-packages/trino-server-rpm/target` directory with the name
`trino-server-rpm-470.noarch.rpm`. The specific version depends on the property
`dep.trino.version` configured in `trino-packages/trino-server-rpm/pom.xml`.

To run the integration tests in `ServerIT` you must activate the `ci` profile.
A local Docker installation is required:

```shell
./mvnw -Pci clean install
```

## Updating to other Trino version

The project is configured to build an RPM for Trino 470. Updates to newer
versions can be contributed to the repository or can be done locally. The
following steps are necessary:

* Update the property `dep.trino.version` in 
  `trino-packages/trino-server-rpm/pom.xml` to the desired Trino version.
* If necessary, adjust the Java version `project.build.targetJdk` and
  `air.java.version` in `trino-packages/trino-server-rpm/pom.xml`.
* Update the `parent` in `trino-packages/pom.xml` to the same version used in
  the desired Trino version.
* Check dependency and plugin versions `trino-packages/trino-server-rpm/pom.xml`.
* Adjust to any build failures.
* Update the documentation in this `README.md` file.

## Installing Trino

Build the project on any machine, and copy the RPM archive from the
`trino-server-rpm/target` directory to the server on which you want to install
Trino.

Use the `rpm` command to install the package:

```shell
rpm -i trino-server-rpm-*.rpm --nodeps
```

Installing the required Java runtime must be managed separately.

The process installs Trino in single node mode, where one node acts as both
coordinator and worker.

## Service script

The RPM installation deploys a service script configured with `systemctl` so
that the service can be started automatically on operating system boot. After
installation, you can manage the Trino server with the `service` command:

```shell
service trino [start|stop|restart|status]
```

<table>
  <tr>
    <th>Command</th>
    <th>Action</th>
  </tr>
  <tr>
    <td><code>start</code></td>
    <td>Starts the server as a daemon and returns its process ID.</td>
  </tr>
  <tr>
    <td><code>stop</code></td>
    <td>Shuts down a server started with either <code>start</code> or <code>run</code>. Sends the SIGTERM signal.</td>
  </tr>
  <tr>
    <td><code>restart</code></td>
    <td>Stops and then starts a running server, or starts a stopped server, assigning a new process ID.</td>
  </tr>
  <tr>
    <td><code>status</code></td>
    <td>Prints a status line, either <em>Stopped pid</em> or <em>Running as pid</em>.</td>
  </tr>
</table>

## Installation directory structure

The RPM installation places Trino files in accordance with the Linux Filesystem
Hierarchy Standard using the following directory structure:

- `/usr/lib/trino/lib/`: Contains the various required libraries. 
- `/usr/lib/trino/lib/plugin`: Plugins such as connectors, UDF support, and others.
- `/etc/trino`: Contains the general Trino configuration files like
  `node.properties`, `jvm.config`, `config.properties`.
- `/etc/trino/catalog`: Catalog configuration files.
- `/etc/trino/env.sh`: Contains the Java installation path used by Trino,
  allows configuring process environment variables, including [secrets](https://trino.io/docs/current/security/secrets.html).
- `/var/log/trino`: Contains the log files.
- `/var/lib/trino/data`: The location of the data directory.
- `/etc/rc.d/init.d/trino`: Contains the service scripts for controlling the
  server process, and launcher configuration for file paths.

The `node.properties` file requires the following two additional properties
since our directory structure is different from what standard Trino expects.

```
catalog.config-dir=/etc/trino/catalog
```

## Configuration

To configure your Trino node further, modify the configuration files in
`/etc/trino`, add any further configuration files in `/etc/trino` and add
catalog configuration files in `etc/trino/catalog`.

## Uninstalling

Uninstalling the RPM is like uninstalling any other RPM, just run:

```shell
rpm -e trino-server-rpm-<version>
```

Note that during uninstall, all Trino-related files are deleted except for
user-created configuration files, copies of the original configuration files
`node.properties.rpmsave` and `env.sh.rpmsave` located in the `/etc/trino`
directory, and the Trino logs directory `/var/log/trino`.


