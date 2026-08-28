#!/usr/bin/env bash
set -euo pipefail

properties_file=/data/server.properties

if [[ "${EULA,,}" != "true" ]]; then
    echo "You must accept the Minecraft EULA by setting EULA=TRUE."
    echo "Read it at: https://aka.ms/MinecraftEULA"
    exit 1
fi

printf 'eula=true\n' > /data/eula.txt

# Update a property only when its corresponding environment variable is set.
set_property() {
    local key=$1
    local environment_variable=$2
    local value=${!environment_variable}
    local temporary_file

    case "$value" in
        *$'\n'*|*$'\r'*)
            echo "Environment variable ${environment_variable} cannot contain a newline." >&2
            exit 1
            ;;
    esac

    temporary_file=$(mktemp "${properties_file}.XXXXXX")
    awk -v property_key="$key" -v property_environment="$environment_variable" '
        BEGIN { updated = 0 }
        index($0, property_key "=") == 1 {
            print property_key "=" ENVIRON[property_environment]
            updated = 1
            next
        }
        { print }
        END {
            if (!updated) {
                print property_key "=" ENVIRON[property_environment]
            }
        }
    ' "$properties_file" > "$temporary_file"
    mv "$temporary_file" "$properties_file"
}

if [[ -f "$properties_file" ]]; then
    [[ -v MAX_PLAYERS ]] && set_property 'max-players' MAX_PLAYERS
    [[ -v MOTD ]] && set_property 'motd' MOTD
    [[ -v RCON_PASSWORD ]] && set_property 'rcon.password' RCON_PASSWORD
    [[ -v RCON_PORT ]] && set_property 'rcon.port' RCON_PORT
    [[ -v SERVER_PORT ]] && set_property 'server-port' SERVER_PORT
    [[ -v VIEW_DISTANCE ]] && set_property 'view-distance' VIEW_DISTANCE
fi

exec java \
    "-Xms${MEMORY_MIN}" \
    "-Xmx${MEMORY_MAX}" \
    -jar /minecraft/paper.jar \
    --nogui