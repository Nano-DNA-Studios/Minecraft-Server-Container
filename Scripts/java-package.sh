#!/usr/bin/env bash
set -euo pipefail

VERSION="${MINECRAFT_VERSION}"

IFS='.' read -r MAJOR MINOR PATCH <<< "${VERSION}"
PATCH="${PATCH:-0}"

if (( MAJOR >= 26 )); then
    echo "openjdk-25-jre"
elif (( MAJOR == 1 && MINOR >= 20 )); then
    echo "openjdk-21-jre"
elif (( MAJOR == 1 && MINOR >= 17 )); then
    echo "openjdk-17-jre"
elif (( MAJOR == 1 && MINOR == 16 )); then
    echo "openjdk-16-jre"
elif (( MAJOR == 1 && MINOR >= 12 )); then
    echo "openjdk-11-jre"
else
    echo "openjdk-8-jre"
fi