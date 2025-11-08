# 🎮 Necesse Dedicated Server Docker Image

A Docker container for running a Necesse dedicated game server, with support for ARM64 architecture.

## 📖 Overview

This Docker image provides a streamlined way to run a Necesse dedicated server with true ARM64 support. Unlike traditional game server containers that rely on SteamCMD (which has limited ARM support), this implementation uses direct server downloads, making it perfectly compatible with platforms like Raspberry Pi and Apple Silicon.

### Why This Image?

- **True ARM64 Support**: Built specifically to work on ARM architecture without emulation
- **Lightweight**: Uses Eclipse Temurin JRE 21 base image for optimal performance
- **Security-Focused**: Runs as non-root user with minimal required permissions
- **Auto-Updates**: Optional automatic server updates without manual intervention
- **Easy Configuration**: All server settings configurable via environment variables
- **Data Persistence**: Reliable volume mapping for world saves and configurations

### Ideal For

- Raspberry Pi home servers
- Apple Silicon (M1/M2/M3) machines
- Low-power dedicated gaming servers
- Docker environments requiring ARM compatibility

## 🌟 Features

- ARM64 compatible (runs on Raspberry Pi and Apple Silicon)
- Direct server downloads without SteamCMD dependency (making true ARM support possible)
- Auto-updates to latest server version (optional)
- Configurable through environment variables
- Persistent save data and configurations
- Non-root container execution
- Docker compose support

> **Note:** Unlike many game server containers, this image doesn't rely on SteamCMD, which has limited ARM support. Instead, it downloads the server files directly, ensuring full compatibility with ARM architectures.

## 🚀 Quick Start

1. Clone this repository:

   ```bash
   git clone https://github.com/Sherpard/necesse-arm64-docker-server.git
   cd necesse-arm64-docker-server
   ```

2. Copy the environment template and configure it:

   ```bash
   cp .env.template .env
   ```

3. Edit the `.env` file with your preferred settings:

   ```env
   SERVER_PORT=14159
   SLOTS=8
   OWNER=admin
   PASSWORD=your_password
   WORLD_NAME=MyWorld
   ```

4. Start the server:
   ```bash
   docker compose up -d
   ```

## ⚙️ Configuration

### Environment Variables

| Variable             | Description                | Default         |
| -------------------- | -------------------------- | --------------- |
| `SERVER_PORT`        | UDP port for the server    | 14159           |
| `SLOTS`              | Maximum number of players  | 8               |
| `OWNER`              | Admin username             | admin           |
| `PASSWORD`           | Server password (optional) |                 |
| `MOTD`               | Message of the day         | Welcome message |
| `PAUSE_WHEN_EMPTY`   | Pause server when empty    | 1               |
| `GIVE_CLIENTS_POWER` | Disable anti-cheat         | 0               |
| `LOG_MODE`           | Logging strategy           | docker          |
| `ZIP_SAVES`          | Compress save files        | 1               |
| `WORLD_NAME`         | Default world name         | MyWorld         |
| `AUTO_UPDATE`        | Auto-update server         | false           |
| `JAVA_MEMORY`        | JVM memory allocation      | 2G              |

### Volumes

- `./data:/home/steam/data` - Server data (saves, configs, logs)
- `./cache:/home/steam/cache` - Download cache for server updates

## 🔧 Maintenance

### Updating the Server

The server can automatically update on startup if `AUTO_UPDATE=true` in your `.env` file.

For manual updates, restart the container:

```bash
docker compose restart
```

### Accessing Logs

View live logs:

```bash
docker compose logs -f
```

## 🛡️ Security Notes

- The container runs as a non-root user
- Anti-cheat is enabled by default (`GIVE_CLIENTS_POWER=0`)
- Server operates on UDP port 14159 by default

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🙏 Acknowledgments

- [Necesse Game](https://necessegame.com/) - The awesome game this server runs
- Original maintainer: Sherpard2
