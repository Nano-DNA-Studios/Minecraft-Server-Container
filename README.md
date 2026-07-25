# Minecraft-Server-Container
A Repo for creating a Docker Container used to host a portable Minecraft Server

## Building a Server Container

To build a new Container for a specific Minecraft Version, the following command can be used :
```
docker build --build-arg MINECRAFT_VERSION=<VERSION> -t minecraft-papermc-server .
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
