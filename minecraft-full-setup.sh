#!/bin/bash
# minecraft-full-setup.sh – Complete, working, no more 404s, no more resets
# Run once as sparky (or your user)

set -e
cd ~

echo "=== Creating Minecraft directory ==="
mkdir -p ~/minecraft && cd ~/minecraft

echo "=== Installing dependencies ==="
sudo apt update -qq
sudo apt install -y temurin-21-jdk screen wget curl jq ufw  # Temurin JDK 21 for ARM64 stability

echo "=== Downloading Paper 1.21.10 (latest stable) ==="
VERSION=$(curl -s https://api.papermc.io/v2/projects/paper | jq -r '.versions[-1]')
BUILD=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/$VERSION" | jq -r '.builds[-1]')
wget -q "https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds/$BUILD/downloads/paper-$VERSION-$BUILD.jar" -O paper.jar

echo "=== Downloading Geyser + Floodgate (latest) ==="
mkdir -p plugins
wget -q "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot" -O plugins/Geyser-Spigot.jar
wget -q "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot" -O plugins/Floodgate-Spigot.jar

echo "=== Accepting EULA & setting Creative mode ==="
echo "eula=true" > eula.txt
cat > server.properties <<EOF
gamemode=creative
force-gamemode=true
online-mode=false
difficulty=easy
view-distance=6
simulation-distance=6
pvp=false
spawn-monsters=false
motd=&6&l🚀 Family Server &a&lCreative Fun! &rJoin Now!
EOF

echo "=== Firewall ==="
sudo ufw allow 25565/tcp
sudo ufw allow 19132/udp
sudo ufw --force reload

echo "=== Done! Server ready. Use ./start-minecraft.sh to run ==="
