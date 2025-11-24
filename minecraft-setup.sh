#!/bin/bash

# Minecraft Paper + GeyserMC + Floodgate Setup Script (Fixed jq/API v2)
# Run in ~/minecraft directory. Handles everything automatically.
# Allocates 12GB RAM (perfect for 5+ players on DGX Spark).
# Latest versions fetched dynamically.

set -e  # Exit on any error

echo "=== Minecraft Crossplay Server Setup (Mac + Switch) ==="
echo "Cleaning old files..."

# Clean
rm -f paper.jar
rm -f plugins/Geyser-Spigot.jar plugins/Floodgate-Spigot.jar 2>/dev/null || true
rm -rf plugins/Geyser plugins/Floodgate 2>/dev/null || true  # Remove old configs

# Install/update deps (jq for JSON parsing)
sudo apt update -qq
if ! command -v jq &> /dev/null; then
    echo "Installing jq..."
    sudo apt install -y jq wget curl screen
fi

# Fetch latest Paper (universal JAR, ARM64 OK)
echo "Fetching latest PaperMC..."
PROJECT_JSON=$(curl -s https://api.papermc.io/v2/projects/paper)
VERSION=$(echo "${PROJECT_JSON}" | jq -r '.versions[-1]')  # Fixed: Direct .versions array
if [ "${VERSION}" = "null" ] || [ -z "${VERSION}" ]; then
    echo "Error fetching version—using fallback 1.21.10"
    VERSION="1.21.10"
fi
BUILD_JSON=$(curl -s "https://api.papermc.io/v2/projects/paper/versions/${VERSION}")
BUILD=$(echo "${BUILD_JSON}" | jq -r '.builds[-1]')
PAPER_URL="https://api.papermc.io/v2/projects/paper/versions/${VERSION}/builds/${BUILD}/downloads/paper-${VERSION}-${BUILD}.jar"
echo "Downloading Paper ${VERSION} build ${BUILD}..."
wget -q -O paper.jar "${PAPER_URL}"

# EULA
echo "eula=true" > eula.txt

# First start: Generate server.properties, plugins/
echo "Generating base files..."
java -Xmx12G -Xms12G -jar paper.jar nogui &
PID=$!
sleep 15  # Wait for generation
kill ${PID} 2>/dev/null || true
wait ${PID} 2>/dev/null || true

# Download plugins (fixed URLs for Spigot/Paper compat)
echo "Downloading GeyserMC & Floodgate (latest)..."
GEYSER_URL=$(curl -s https://api.geysermc.org/v2/projects/geyser/versions/latest | jq -r '.builds[-1].downloads.spigot.url // empty')
if [ -n "${GEYSER_URL}" ]; then
    wget -q -O plugins/Geyser-Spigot.jar "${GEYSER_URL}"
else
    echo "Fallback Geyser download..."
    wget -q -O plugins/Geyser-Spigot.jar "https://download.geysermc.org/v2/projects/geyser/builds/latest/downloads/spigot"
fi
FLOODGATE_URL=$(curl -s https://api.geysermc.org/v2/projects/floodgate/versions/latest | jq -r '.builds[-1].downloads.spigot.url // empty')
if [ -n "${FLOODGATE_URL}" ]; then
    wget -q -O plugins/Floodgate-Spigot.jar "${FLOODGATE_URL}"
else
    echo "Fallback Floodgate download..."
    wget -q -O plugins/Floodgate-Spigot.jar "https://download.geysermc.org/v2/projects/floodgate/builds/latest/downloads/spigot"
fi

# Disable online-mode (required for Floodgate)
if grep -q "online-mode=true" server.properties 2>/dev/null; then
    sed -i 's/online-mode=true/online-mode=false/g' server.properties
fi

# Second start: Generate plugin configs
echo "Generating plugin configs..."
java -Xmx12G -Xms12G -jar paper.jar nogui &
PID=$!
while [ ! -f plugins/Geyser/config.yml ] 2>/dev/null || [ ! -s plugins/Geyser/config.yml ]; do
    sleep 1
done
sleep 5  # Extra time
kill ${PID} 2>/dev/null || true
wait ${PID} 2>/dev/null || true

# Auto-config Geyser (Bedrock port/auth) - safer sed
CONFIG=plugins/Geyser/config.yml
if [ -f "${CONFIG}" ]; then
    sed -i.bak '/bedrock:/,/^[^ ]/ {
        /address:/c\  address: 0.0.0.0
        /port:/c\  port: 19132
    }' "${CONFIG}" || {
        # Fallback: Replace lines if sed fails on YAML
        sed -i.bak 's/^  address: .*/  address: 0.0.0.0/' "${CONFIG}"
        sed -i.bak 's/^  port: .*/  port: 19132/' "${CONFIG}"
        sed -i.bak 's/^auth-type: .*/auth-type: floodgate/' "${CONFIG}"
    }
    rm -f "${CONFIG}.bak"
fi

# Firewall (Java 25565/TCP, Bedrock 19132/UDP)
echo "Configuring firewall..."
sudo ufw allow 25565/tcp comment "Minecraft Java" || true
sudo ufw allow 19132/udp comment "Minecraft Bedrock" || true
sudo ufw --force reload || true

echo "=== SETUP COMPLETE! ==="
echo ""
echo "1. Start server: screen -S mc"
echo "2. Inside screen: cd ~/minecraft && java -Xmx12G -Xms12G -jar paper.jar nogui"
echo "3. Detach: Ctrl+A then D"
echo "4. Reattach: screen -r mc"
echo "5. Stop: Type 'stop'"
echo ""
echo "Connect:"
echo "  - Mac (Java): $(hostname -I | awk '{print $1}'):25565"
echo "  - Switch (Bedrock): DNS=104.238.130.180, Servers > IP:19132"
echo ""
echo "Local LAN = 0 lag! Enjoy building with kids! 🚀"
echo "If issues: Check logs/latest/ for 'Geyser enabled' on next start."
