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
COPY ./Scripts/download-paper.sh /usr/local/bin/download-paper
RUN chmod +x /usr/local/bin/download-paper && /usr/local/bin/download-paper

# ------------------------------------------------------------
# Run Paper
# ------------------------------------------------------------
FROM ubuntu:24.04

# Define Arguments 
ARG MINECRAFT_VERSION

# Define Default Environment Variables
ENV DEBIAN_FRONTEND=noninteractive
ENV MINECRAFT_UID=1001
ENV MINECRAFT_GID=1001
ENV EULA=TRUE
ENV MEMORY_MIN=2G 
ENV MEMORY_MAX=6G

# Copy the script to determine the Java Package
COPY ./Scripts/java-package.sh /usr/local/bin/java-package
RUN chmod +x /usr/local/bin/java-package

# Run the script to find the Java Package and install it along with tini for proper signal handling
RUN JAVA_PACKAGE="$(/usr/local/bin/java-package)" \
    && apt-get update \
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
RUN mkdir -p /minecraft /data \
    && chown -R minecraft /minecraft /data

# Copy the downloaded Paper jar from the downloader stage to the final image
COPY --from=downloader --chown=minecraft /paper.jar /minecraft/paper.jar

# Copy the entrypoint script to the final image and make it executable
COPY ./Scripts/entrypoint.sh /usr/local/bin/minecraft-entrypoint
RUN chmod +x /usr/local/bin/minecraft-entrypoint

WORKDIR /data

VOLUME ["/data"]

EXPOSE 25565/tcp

USER minecraft

STOPSIGNAL SIGTERM

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/minecraft-entrypoint"]