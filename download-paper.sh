#!/usr/bin/env bash
set -euo pipefail

MINECRAFT_VERSION="${MINECRAFT_VERSION}"
PAPER_USER_AGENT="${PAPER_USER_AGENT}"
OUTPUT_FILE="${OUTPUT_FILE:-/paper.jar}"

BUILD_JSON="$(
    curl \
        --fail \
        --silent \
        --show-error \
        --header "User-Agent: ${PAPER_USER_AGENT}" \
        "https://fill.papermc.io/v3/projects/paper/versions/${MINECRAFT_VERSION}/builds/latest"
)"

PAPER_URL="$(
    printf '%s' "${BUILD_JSON}" |
        jq -r '.downloads."server:default".url'
)"

PAPER_SHA256="$(
    printf '%s' "${BUILD_JSON}" |
        jq -r '.downloads."server:default".checksums.sha256'
)"

if [[ -z "${PAPER_URL}" || "${PAPER_URL}" == "null" ]]; then
    echo "Could not determine the Paper download URL."
    exit 1
fi

if [[ -z "${PAPER_SHA256}" || "${PAPER_SHA256}" == "null" ]]; then
    echo "Could not determine the Paper SHA-256 checksum."
    exit 1
fi

echo "Downloading Paper for Minecraft ${MINECRAFT_VERSION}..."

curl \
    --fail \
    --location \
    --show-error \
    --header "User-Agent: ${PAPER_USER_AGENT}" \
    "${PAPER_URL}" \
    --output "${OUTPUT_FILE}"

echo "${PAPER_SHA256}  ${OUTPUT_FILE}" | sha256sum --check

echo "Paper downloaded successfully to ${OUTPUT_FILE}."