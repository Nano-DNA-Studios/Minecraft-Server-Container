# Minecraft-Server-Container
A Repo for creating a Docker Container used to host a portable PaperMC Minecraft Server

## Building a Server Container

To build a new Container for a specific Minecraft Version, the following command can be used :
```
docker build --build-arg MINECRAFT_VERSION=<VERSION> -t minecraft-papermc-server:latest .
```

## Running Minecraft Server
To run the Minecraft Server, the following command can be used :
```
docker run -d --name minecraft --restart unless-stopped -p 25565:25565 -e MEMORY_MIN=2G -e MEMORY_MAX=6G -v minecraft-data:/data minecraft-papermc-server
```

Note : The `MEMORY_MIN` and `MEMORY_MAX` values are Optional to override.

## Minecraft Server Version to Java Mapping

| Minecraft / Paper version | Recommended Java version |
| ------------------------- | ------------------------ |
| 1.7.10–1.11               | Java 8                   |
| 1.12–1.16.4               | Java 11                  |
| 1.16.5                    | Java 16                  |
| 1.17–1.19.x               | Java 17                  |
| 1.20–1.21.11              | Java 21                  |
| 26.1 and newer            | Java 25                  |

## Server properties

The container starts with the defaults in `Data/server.properties`. Override these properties at runtime by passing any of the following environment variables:

| Environment variable | Server property |
| -------------------- | --------------- |
| `MAX_PLAYERS`        | `max-players`   |
| `MOTD`               | `motd`          |
| `RCON_PASSWORD`      | `rcon.password` |
| `RCON_PORT`          | `rcon.port`     |
| `SERVER_PORT`        | `server-port`   |
| `VIEW_DISTANCE`      | `view-distance` |

For example:

```sh
docker run --rm \
  -e MAX_PLAYERS=50 \
  -e MOTD='Minecraft Server' \
  -e RCON_PASSWORD='change-me' \
  -e RCON_PORT=25575 \
  -e SERVER_PORT=25565 \
  -e VIEW_DISTANCE=16 \
  minecraft-papermc-server
```

Only variables that are explicitly set are applied, so unset variables retain the values from `server.properties`.

The current defaults are :

| Server property       | Value            |
| --------------------- | ---------------- |
| `max-players`         | 20               |
| `motd`                | Minecraft Server |
| `rcon.password`       | RCONPASSWORD     |
| `rcon.port`           | 25575            |
| `server-port`         | 25565            |
| `view-distance`       | 16               |
| `simulation-distance` | 20               |
