# Custom Trino Docker image

This project is an example setup for creating a custom Docker image of Trino
built on top of the `trinodb/trino-core` image available with Trino 472 and
newer. The example includes configuration files, a limited subset of Trino
plugins, and instructions for your own customizations.

Use it as a base to create your own custom image suitable for your needs with
different deployment use cases and clusters. 

The following sections contain information for building, using, and customizing
the image.

## General information

Users can use the Trino Docker image directly, with Docker compose, with the
[Trino Helm charts](https://trinodb.github.io/charts/) or other deplopyment
tools.

The Trino project provides a `trinodb/trino-core` image tarball with the minimal
plugins and a default `trinodb/trino-core` image with all available plugins.
Both images also include the Trino CLI and can be started successfully without
further configuration. Details for running and using the image are available in
the
[Trino documentation](https://trino.io/docs/current/installation/containers.html).

This project uses the core image and adds necessary configuration files and a
limited subset of plugins to create a image with the following characteristics:

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
* Node configured to act as coordinator and worker to allow single node use.
* Environment name set to `custom` in `node.properties`.
* No additional logging configured in `log.properties`.
* Preview Web UI enabled.
* `geospatial` functions plugin removed.
* `exchange-filesystem` plugin removed.

The project is configured for Trino 474.

## Building

Build requirements:

* Linux or MacOS with bash shell (others might work but are untested)
* Docker (or equivalent tool)

Download and extract or clone the repository to work with the `custom-docker`
directory locally on your machine.

Run the build script:

```shell
cd custom-docker
./build.sh
```

The project uses the `trino-core` Docker images for the the configured Trino
release, adds configurations files from `customization` and a limited number of
plugins configured in `processPluginsForCustomizations` in `build.sh`, and
repackages it into a Docker image.

After a successful build, you find the Docker images for the three different
processor architectures locally with `docker images`:

```
REPOSITORY     TAG           IMAGE ID       CREATED              SIZE
trino-custom   474-ppc64le   2279b0a14cb6   About a minute ago   790MB
trino-custom   474-arm64     67a3dcee3c85   About a minute ago   765MB
trino-custom   474-amd64     df994bb44819   About a minute ago   757MB
```

The specific version depends on the parameter `TRINO_VERSION` set in `build.sh`.
Run `./build.sh -h` for options of the script to modify the version, the
architectures, and the tag. Note that customizations you must manually adjust
files in `customization` to any version changes.

## Installation

Build the project on any machine and run the container by specifying the
container with the appropriate processor architecture. The included
configuration and set up is suitable for a single node Trino cluster for testing
purposes. The Trino node functions both as a coordinator and a worker. To launch
it, execute the following:

```shell
docker run -p 8080:8080 --name trino-custom  trino-custom:474-arm64
```

Wait for the following message log line:

```
INFO	main	io.trino.server.Server	======== SERVER STARTED ========
```

The Trino server is now running on `localhost:8080` (the default port).

Connect with the Trino CLI or any other client to explore catalogs and schemas,
and run your SQL queries.

After testing, remove the container:

```shell
docker rm trino-custom
```

Find details for using the main `trinodb:trino` image, the `trinodb:trino-core`
and therefore also the resulting image from this project in the [Trino Docker
images
documentation](https://trino.io/docs/current/installation/containers.html) and
the [Trino Helm chart documentation](https://trinodb.github.io/charts/)

Use `docker tag`, `docker push`, and `docker manifest` to publish the image to a
registry and use it from there on other machines directly or with the Helm
chart. Refer to the [Trino Docker release
script](https://github.com/trinodb/release-scripts/blob/master/trino-docker.sh)
for an example setup.

## Customization

The project setup is an example and can be customized to suit your needs with
some of the following steps:

* Customize the overlay for the root file system in `customization`,
  specifically some of the following items.
* Customize your configuration by modifying the files in
  `customization/etc/trino`.
* Add further configuration files in `customization/etc/trino`.
* Add catalogs by adding catalog properties files in
  `customization/etc/trino/catalog` and adding the relevant connector plugins
  `processPluginsForCustomizations` in `build.sh`.
* Remove any unwanted configurations and catalogs in `customization`. 
* Remove any unwanted plugins in `processPluginsForCustomizations` in `build.sh`.
* Add custom plugins as GAV parameters or URLs in
  `processPluginsForCustomizations` in `build.sh` or as extracted directories of
  JAR files in `customization/usr/lib/trino/plugin/`.
* Remove any further unwanted files such as plugins from the container in the
  `Dockerfile` with a `RUN rm` command. Keep in mind that this only hides the
  layer and does NOT reduce the size of the image.

Use multiple copies of the project to create different Docker images for
different use cases.

Refer to the [plugin
documentation](https://trino.io/docs/current/installation/plugins.html) and
other Trino documentation for more details.

## Updating to other Trino version

The project is configured to build a custom tarball for Trino 474. Updates to
newer versions can be contributed to the repository or can be done locally. The
following steps are necessary:

* Update the parameter `TRINO_VERSION` set in  in `build.sh` to the desired
  Trino version.
* If necessary, adjust the included configuration files in `customization`.
* Update the documentation in this `README.md` file.
