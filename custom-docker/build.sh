#!/usr/bin/env bash

set -euo pipefail

usage() {
    cat <<EOF 1>&2
Usage: $0 [-h] [-a <ARCHITECTURES>] [-r <TRINO_VERSION>] [-t <TAG_PREFIX>]
Builds the Trino Docker image

-h       Display help
-a       Build the specified comma-separated architectures, defaults to amd64,arm64,ppc64le
-r       Trino version, defaults to 475
-t       Image tag name, defaults to trino-custom
EOF
}

ARCHITECTURES=(amd64 arm64 ppc64le)
# Set the desires Trino version. This version is also used automatically in the
# Dockerfile.
TRINO_VERSION=475
TAG_PREFIX=trino-custom

while getopts ":a:r:t:h" o; do
    case "${o}" in
        a)
            IFS=, read -ra ARCH_ARG <<< "$OPTARG"
            for arch in "${ARCH_ARG[@]}"; do
                if echo "${ARCHITECTURES[@]}" | grep -v -w "$arch" &>/dev/null; then
                    usage
                    exit 0
                fi
            done
            ARCHITECTURES=("${ARCH_ARG[@]}")
            ;;
        r)
            TRINO_VERSION=${OPTARG}
            ;;
        t)
            TAG_PREFIX=${OPTARG}
            ;;
        h)
            usage
            exit 0
            ;;
        *)
            usage
            exit 1
            ;;
    esac
done
shift $((OPTIND - 1))

echo "Trino version set to ${TRINO_VERSION}"
echo "Architectures set to ${ARCHITECTURES[@]}"
echo "Tag prefix set to ${TAG_PREFIX}"

# Download a plugin from any URL. Must be a Trino plugin zip file.
# Specify the URL and the name for the desired folder in the plugin directory.
function downloadUrlPlugin() {
    url=$1
    folder=$2
    filename=$(basename ${url})
    echo "Download ${url}"
    curl ${url} --fail --location --silent --output ${filename}
    unzip -q ${filename}
    tmp=$(basename ${filename} .zip)
    echo "Add plugin ${tmp} as ${folder} directory"
    mv ${tmp} customization/usr/lib/trino/plugin/${folder}
    rm ${filename}
}

# Download a plugin from Maven Central.
# Specify the group path (groupId translated to a path), artifactid, version,
# and name for the desired folder in the plugin directory.
function downloadPlugin() {
    groupPath=$1
    artifactid=$2
    version=$3
    folder=$4
    filename="${artifactid}-${version}.zip"
    url="https://repo1.maven.org/maven2/${groupPath}/${artifactid}/${version}/$filename"
    downloadUrlPlugin ${url} ${folder}
}

# Download any Trino plugin from Maven Central.
# Specify the group path (groupId translated to a path), artifactid, version, 
# and name for the desired folder in the plugin directory.
function downloadGavPlugin() {
    groupPath=$1
    artifactid=$2
    version=$3
    folder=$4
    downloadPlugin ${groupPath} ${artifactid} ${version} ${folder}
}

# Download a core Trino plugin with path io/trino from Maven Central.
# Specify artifactid, version, and name for the desired folder in the plugin directory.
function downloadTrinoPlugin() {
    artifactid=$1
    version=$2
    folder=$3
    downloadGavPlugin 'io/trino' ${artifactid} ${version} ${folder}
}

# Download the desired Trino plugins.
# Use the functions above as desired to download plugins from Maven Central
# or other URLs.
function processPluginsForCustomizations() {
    echo "Download plugins for customization"
    downloadTrinoPlugin 'trino-ai-functions' ${TRINO_VERSION} 'ai-functions'
    downloadTrinoPlugin 'trino-blackhole' ${TRINO_VERSION} 'blackhole'
    downloadTrinoPlugin 'trino-faker' ${TRINO_VERSION} 'faker'
    downloadTrinoPlugin 'trino-jmx' ${TRINO_VERSION} 'jmx'
    downloadTrinoPlugin 'trino-memory' ${TRINO_VERSION} 'memory'
    #downloadTrinoPlugin 'trino-tpch' ${TRINO_VERSION} 'tpch'
    # Equivalent to the preceding line as example for the downloadGavPlugin function
    downloadGavPlugin 'io/trino' 'trino-tpch' ${TRINO_VERSION} 'tpch'
    #downloadTrinoPlugin 'trino-tpcds' ${TRINO_VERSION} 'tpcds'
    # Equivalent to the preceding line as example for the downloadUrlPlugin function
    downloadUrlPlugin "https://repo1.maven.org/maven2/io/trino/trino-tpcds/${TRINO_VERSION}/trino-tpcds-${TRINO_VERSION}.zip" 'tpcds'
}

echo "Clean up from prior builds"
rm -rf target
mkdir -p target/customization
echo "Copy customization files"
cp -r customization/* target/customization
mkdir -p target/customization/usr/lib/trino/plugin

cd target
processPluginsForCustomizations
cd ..


TAG="${TAG_PREFIX}:${TRINO_VERSION}"
printf "Building images ${TAG}\n\n"

# Fix for build issue with 
#"failed to resolve source metadata" behind proxy/vpn
#export BUILDKIT_NO_CLIENT_TOKEN=1

for arch in "${ARCHITECTURES[@]}"; do
    echo "Building image for ${TAG} and $arch"
    docker build . \
        --progress=plain \
        --pull \
        --build-arg TRINO_VERSION="${TRINO_VERSION}" \
        --build-arg ARCH="${arch}" \
        --platform "linux/$arch" \
        -f Dockerfile \
        -t "${TAG}-$arch"
done
