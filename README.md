# Minecraft-Server-Container
A Repo for creating a Docker Container used to host a portable PaperMC Minecraft Server

## Building a Server Container

To build a new Container for a specific Minecraft Version, the following command can be used :
```
docker build --build-arg MINECRAFT_VERSION=<VERSION> -t minecraft-papermc-server:latest .
```

## Running Minecraft Server
To run the Minecraft Server, the following command can be used :

## Running the Server
The server has been designed to be easily run and transferrable, it is stuffed within a Docker container which can be run anywhere.

The bare minimum to run the server is using the following command :
```
docker run -d --name minecraft --restart unless-stopped -p 25565:25565 -e MEMORY_MIN=2G -e MEMORY_MAX=6G -v minecraft-data:/data minecraft-papermc-server
```

Note : The `MEMORY_MIN` and `MEMORY_MAX` values are Optional to override.

It is suggested to use the Minecraft Server Controller alongside the Minecraft Server, meaning it should be run within a Docker Compose deployment. The suggested compose file should be used as a template :
### Docker Compose 
```yml
services:
  app:
    user: "0:0"
    image: ghcr.io/nano-dna-studios/minecraft-server-controller:latest
    container_name: minecraft-server-controller
    env_file:
      - ./.env
    ports:
      - ${ControllerPort}:80
    volumes:
      - type: volume
        source: mc-data
        target: /data
        volume:
          nocopy: true
      - ./backup:/backup
      - /var/run/docker.sock:/var/run/docker.sock
  server:
    image: ghcr.io/nano-dna-studios/minecraft-papermc-server:26.2
    container_name: minecraft-papermc-server
    env_file:
      - ./.env
    environment:
      - MEMORY_MIN=2G
      - MEMORY_MAX=10G
    ports:
      - ${SERVER_PORT}:25565
      - ${MapPort}:8123
    volumes:
      - mc-data:/data
volumes:
  mc-data:
```

### Environment
And the following Environment Variables should be used :
```
RCONHost=server
Delay=5000
NumOfBackups=3
ControllerPort=8081
ServerContainerName=<container-name>

# Dynmap Settings
MapHealthUrl=http://server:8123/
MapBrowserUrl=http://<local-ip>:8123/
MapPort=8123

# Server Properties
MAX_PLAYERS=20
MOTD=<NAME>
RCON_PASSWORD=<PASSWORD>
RCON_PORT=25575
SERVER_PORT=25565
VIEW_DISTANCE=<16-32>
SIM_DISTANCE=<16-32>
```

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
