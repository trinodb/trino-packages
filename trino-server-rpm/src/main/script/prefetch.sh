#!/usr/bin/env bash
#
# Download the trino-server tarball from the Trino GitHub release for the
# configured version and install it into the local Maven repository so that
# provisio can resolve it by GAV via the <artifact> entry in
# src/main/provisio/trino.xml.
#
# Trino no longer publishes trino-server tar.gz to Maven Central as of Trino
# 477. The provisio descriptor remains the single source of truth for what
# artifacts to fetch — the active (non-commented) <artifact> entries are
# parsed out of it and downloaded one by one.
#
# The artifact is skipped entirely if it is already present in the local
# Maven repository for the requested version, so repeated `clean install`
# runs do not re-download the multi-hundred MB server tarball.
#
# Arguments:
#   $1  Trino version (for example 482)
#   $2  Project basedir (the trino-server-rpm module directory)
#   $3  Work directory for caching downloads (typically ${project.build.directory})

set -euo pipefail

VERSION="${1:?usage: prefetch.sh <trino-version> <project-basedir> <work-dir>}"
BASEDIR="${2:?missing project basedir}"
WORKDIR="${3:?missing work dir}"

PROVISIO_XML="${BASEDIR}/src/main/provisio/trino.xml"
DOWNLOAD_DIR="${WORKDIR}/prefetch"
GITHUB_BASE="https://github.com/trinodb/trino/releases/download/${VERSION}"
MVN="${BASEDIR}/../mvnw"
LOCAL_REPO="${HOME}/.m2/repository"

mkdir -p "${DOWNLOAD_DIR}"

# Strip XML comments (possibly multi-line) and extract every <artifact id="...">
# value. The provisio descriptor uses ${project.groupId} and ${dep.trino.version}
# placeholders that get substituted here using the version passed in by Maven.
artifacts=$(perl -0777 -pe 's/<!--.*?-->//gs' "${PROVISIO_XML}" \
  | grep -oE '<artifact id="[^"]+"' \
  | sed -E 's/<artifact id="//; s/"$//')

if [ -z "${artifacts}" ]; then
  echo "No active <artifact> entries found in ${PROVISIO_XML}" >&2
  exit 1
fi

for artifact in ${artifacts}; do
  resolved=$(echo "${artifact}" \
    | sed "s/\${project.groupId}/io.trino/g" \
    | sed "s/\${dep.trino.version}/${VERSION}/g")

  group=$(echo "${resolved}" | cut -d: -f1)
  artifact_id=$(echo "${resolved}" | cut -d: -f2)
  packaging=$(echo "${resolved}" | cut -d: -f3)
  artifact_version=$(echo "${resolved}" | cut -d: -f4)

  filename="${artifact_id}-${artifact_version}.${packaging}"
  repo_path="${LOCAL_REPO}/${group//.//}/${artifact_id}/${artifact_version}/${filename}"

  if [ -f "${repo_path}" ]; then
    echo "Already installed: ${group}:${artifact_id}:${packaging}:${artifact_version}"
    continue
  fi

  local_path="${DOWNLOAD_DIR}/${filename}"

  if [ ! -f "${local_path}" ]; then
    url="${GITHUB_BASE}/${filename}"
    echo "Downloading ${url}"
    # Force HTTP/1.1 to avoid intermittent HTTP/2 stream errors on large
    # GitHub release assets. Retry on any error including transient mid-stream
    # failures. Write to a .tmp file and rename on success so a partial
    # download cannot be mistaken for a cached complete file.
    curl --fail --location --silent --show-error \
         --http1.1 \
         --retry 10 --retry-delay 10 --retry-all-errors \
         --connect-timeout 60 --max-time 1800 \
         --output "${local_path}.tmp" "${url}"
    mv "${local_path}.tmp" "${local_path}"
  else
    echo "Using cached ${filename}"
  fi

  echo "Installing ${group}:${artifact_id}:${packaging}:${artifact_version} into local Maven repository"
  "${MVN}" -B -q install:install-file \
    -Dfile="${local_path}" \
    -DgroupId="${group}" \
    -DartifactId="${artifact_id}" \
    -Dversion="${artifact_version}" \
    -Dpackaging="${packaging}"
done
