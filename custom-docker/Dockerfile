# Set default to invalid version to ensure override in build.sh
ARG TRINO_VERSION=472
FROM trinodb/trino-core:${TRINO_VERSION}

# Add customization
COPY --chown=trino:trino target/customization /

# Remove any unwanted files such as plugins that are included in the base image.
# Keep in mind that this only hides the layer and does NOT reduce the size 
# of the image.
#RUN rm -rf /usr/lib/trino/plugin/geospatial \
#        /usr/lib/trino/plugin/exchange-filesystem
