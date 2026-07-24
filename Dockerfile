# ------------------------------------------------------------
# Download Paper
# ------------------------------------------------------------
FROM ubuntu:24.04 AS downloader

# Define Arguments 
ARG MINECRAFT_VERSION

# Install Necessary Tools
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Run the download script to fetch the latest Paper jar for the specified Minecraft version
COPY download-paper.sh /usr/local/bin/download-paper
RUN chmod +x /usr/local/bin/download-paper && /usr/local/bin/download-paper

# ------------------------------------------------------------
# Run Paper
# ------------------------------------------------------------
FROM ubuntu:24.04

ARG MINECRAFT_VERSION

ENV DEBIAN_FRONTEND=noninteractive
ENV MINECRAFT_UID=1001
ENV MINECRAFT_GID=1001
ENV EULA=TRUE
ENV MEMORY_MIN=2G 
ENV MEMORY_MAX=6G
ENV JAVA_PACKAGE=openjdk-25-jre

# Find the correct Java package for the given Minecraft version
COPY java-package.sh /usr/local/bin/java-package
RUN chmod +x /usr/local/bin/java-package && JAVA_PACKAGE="$(/usr/local/bin/java-package)"

# Install necessary packages including the correct Java version and tini for proper signal handling
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        "${JAVA_PACKAGE}"-headless \
        tini \
    && rm -rf /var/lib/apt/lists/* 

# Create a non-root user and group for running the Minecraft server
RUN groupadd --gid "${MINECRAFT_GID}" minecraft \
    && useradd \
        --create-home \
        --uid "${MINECRAFT_UID}" \
        --gid "${MINECRAFT_GID}" \
        --shell /bin/bash minecraft

# Create directories for Minecraft server and set ownership to the minecraft user
RUN mkdir -p /opt/minecraft /data \
    && chown -R minecraft /opt/minecraft /data

# Copy the downloaded Paper jar from the downloader stage to the final image
COPY --from=downloader --chown=minecraft /paper.jar /opt/minecraft/paper.jar

# Copy the entrypoint script to the final image and make it executable
COPY entrypoint.sh /usr/local/bin/minecraft-entrypoint
RUN chmod +x /usr/local/bin/minecraft-entrypoint

WORKDIR /data

VOLUME ["/data"]

EXPOSE 25565/tcp

USER minecraft

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/minecraft-entrypoint"]