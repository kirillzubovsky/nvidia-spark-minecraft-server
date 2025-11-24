# Nvidia Spark Minecraft Server

A complete setup guide for running a Minecraft server with cross-platform play (Java + Bedrock) on Nvidia Spark DGX systems. Perfect for local LAN gaming with kids, supporting both PC/Mac (Java Edition) and Nintendo Switch/Mobile (Bedrock Edition) players!

## Features

- **Cross-platform play**: Java Edition (PC/Mac) and Bedrock Edition (Switch/Mobile/Xbox) on the same server
- **Optimized for Nvidia Spark**: Configured for ARM64 architecture with 12GB RAM allocation
- **Zero-lag local play**: Perfect for family gaming on local network
- **Automatic setup**: Scripts handle all configuration automatically
- **Latest versions**: Always fetches the latest Paper, Geyser, and Floodgate builds

## Prerequisites

- Nvidia Spark DGX system (or any ARM64/x86_64 Linux system)
- Java 17 or higher
- At least 16GB RAM (server uses 12GB)
- Ubuntu/Debian-based OS
- Network access for downloading server files

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/nvidia-spark-minecraft-server.git
cd nvidia-spark-minecraft-server
```

### 2. Run the Setup Script

```bash
chmod +x minecraft-setup.sh
./minecraft-setup.sh
```

This script will:
- Download the latest PaperMC server
- Install GeyserMC and Floodgate for cross-platform support
- Configure all necessary settings
- Set up firewall rules

### 3. Configure Server (Optional)

Copy the example configuration:
```bash
cp server.properties.example server.properties
```

Edit `server.properties` to customize:
- `motd=` - Server name shown in multiplayer list
- `level-seed=` - World generation seed
- `gamemode=` - creative/survival/adventure/spectator
- `difficulty=` - peaceful/easy/normal/hard
- `max-players=` - Maximum concurrent players

**Important**: Keep `online-mode=false` for Geyser/Floodgate to work!

### 4. Start the Server

Using screen (recommended):
```bash
screen -S minecraft
java -Xmx12G -Xms12G -jar paper.jar nogui
```

Detach from screen: `Ctrl+A` then `D`
Reattach later: `screen -r minecraft`

Or use the provided start script:
```bash
./start-minecraft.sh
```

### 5. Connect to Your Server

Find your server IP:
```bash
hostname -I | awk '{print $1}'
```

#### For Java Edition (PC/Mac):
1. Open Minecraft Java Edition
2. Click "Multiplayer" → "Add Server"
3. Enter your server IP: `[YOUR-IP]:25565`
4. Click "Done" and connect!

#### For Bedrock Edition (Switch/Mobile/Xbox):

**Nintendo Switch Setup:**
1. System Settings → Internet → Internet Settings
2. Select your network → Change Settings → DNS Settings → Manual
3. Primary DNS: `104.238.130.180`
4. Secondary DNS: `1.1.1.1`
5. Save and connect
6. In Minecraft, go to Servers tab
7. Your server appears at the bottom
8. If not visible, click "Add Server" and use IP: `[YOUR-IP]:19132`

**Mobile/Xbox:**
- Simply add server with IP: `[YOUR-IP]:19132`

## Server Management

### Stop the Server
In the server console:
```
stop
```

Or use the script:
```bash
./stop-minecraft.sh
```

### Backup Worlds
```bash
./backup-world.sh
```

### Update Server
Re-run the setup script to get latest versions:
```bash
./minecraft-setup.sh
```

### Add Operators (Admins)
In server console:
```
op [playername]
```

### Whitelist Players (Optional)
```bash
cp whitelist.json.example whitelist.json
```
Edit `whitelist.json` with player names/UUIDs, then:
```
whitelist on
whitelist reload
```

## Performance Tuning

The server is pre-configured for optimal performance on Nvidia Spark:
- **RAM**: 12GB allocated (adjust in start scripts if needed)
- **View Distance**: Set to 5 chunks (good balance)
- **Simulation Distance**: 5 chunks

For more players or larger worlds, edit `server.properties`:
```properties
view-distance=10  # Increase for larger visible area
simulation-distance=10  # Increase for more active chunks
max-players=50  # Allow more players
```

## Troubleshooting

### Server Won't Start
- Check Java version: `java -version` (need Java 17+)
- Ensure enough RAM available
- Check logs: `cat logs/latest.log`

### Can't Connect from Bedrock
- Verify port 19132/UDP is open: `sudo ufw status`
- Check Geyser is running: Look for "Geyser enabled" in logs
- Ensure `online-mode=false` in server.properties

### Switch Can't See Server
- Double-check DNS is set to `104.238.130.180`
- Try restarting Minecraft on Switch
- Manually add server with your local IP and port 19132

### Performance Issues
- Reduce view-distance in server.properties
- Check system resources: `htop`
- Restart server to clear memory

## File Structure

```
nvidia-spark-minecraft-server/
├── minecraft-setup.sh        # Main setup script
├── start-minecraft.sh        # Server start script
├── stop-minecraft.sh         # Server stop script
├── backup-world.sh          # World backup script
├── server.properties.example # Example configuration
├── whitelist.json.example   # Example whitelist
├── .gitignore              # Git ignore rules
└── README.md               # This file
```

## Security Notes

- The server runs with `online-mode=false` to support cross-platform play
- Use whitelist for private servers: `whitelist on`
- Keep firewall enabled and only open required ports
- Never share your `management-server-secret` if using remote management

## Plugin Support

The server uses Paper, which supports Spigot and Bukkit plugins. To add plugins:

1. Download `.jar` files
2. Place in `plugins/` folder
3. Restart server

Recommended plugins:
- EssentialsX - Basic commands and economy
- WorldEdit - Building tools
- LuckPerms - Advanced permissions
- Dynmap - Web-based world map

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

## License

MIT License - See LICENSE file for details

## Acknowledgments

- [PaperMC](https://papermc.io/) - High-performance Minecraft server
- [GeyserMC](https://geysermc.org/) - Cross-platform bridge
- [Floodgate](https://github.com/GeyserMC/Floodgate) - Bedrock authentication
- Nvidia Spark community for ARM64 optimization tips

## Support

For issues or questions:
- Open an issue on GitHub
- Check [PaperMC docs](https://docs.papermc.io/)
- Visit [GeyserMC wiki](https://wiki.geysermc.org/)

---

**Happy Gaming!** 🎮 Enjoy lag-free Minecraft with your family on Nvidia Spark!