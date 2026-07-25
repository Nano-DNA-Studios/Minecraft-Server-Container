#!/usr/bin/env bash
set -euo pipefail

if [[ "${EULA,,}" != "true" ]]; then
    echo "You must accept the Minecraft EULA by setting EULA=TRUE."
    echo "Read it at: https://aka.ms/MinecraftEULA"
    exit 1
fi

printf 'eula=true\n' > /data/eula.txt

exec java \
    "-Xms${MEMORY_MIN}" \
    "-Xmx${MEMORY_MAX}" \
    -jar /minecraft/paper.jar \
    --nogui