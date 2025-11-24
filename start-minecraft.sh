#!/bin/bash
# start-minecraft.sh – Final version (detached daemon + interactive world menu)

cd ~/minecraft || { echo "Error: ~/minecraft not found!"; exit 1; }

# Get local IP
IP=$(hostname -I | awk '{for(i=1;i<=NF;i++) if($i~/^(192\.168|10\.|172\.)/){print $i;exit}}')
[ -z "$IP" ] && IP="YOUR_IP_HERE"

# Stop any running server cleanly
if [ -f minecraft.pid ]; then
    echo "Stopping existing server (PID $(cat minecraft.pid))..."
    kill $(cat minecraft.pid) 2>/dev/null && sleep 10
    rm -f minecraft.pid
fi

clear
echo "Minecraft Cross-Play Server Launcher"
echo "Local IP: $IP"
echo
echo "1) Launch with current world (fast)"
echo "2) Customize world before launch"
echo
read -p "Choose [1-2]: " choice

if [ "$choice" = "2" ]; then
    echo
    echo "World Customization"
    echo "1) Superflat (best for Creative)"
    echo "2) Void world"
    echo "3) Amplified (huge mountains)"
    echo "4) Large Biomes"
    echo "5) Custom seed"
    echo "6) Upload pre-made world (from ~/world_upload/)"
    echo
    read -p "Choose [1-6]: " custom

    # Backup current world
    echo "Backing up current world..."
    mkdir -p ~/minecraft_backups
    cp -r world world_nether world_the_end ~/minecraft_backups/backup_$(date +"%Y%m%d_%H%M%S")/ 2>/dev/null || true

    rm -rf world world_nether world_the_end

    case $custom in
        1) echo "level-type=FLAT" > level-type.tmp
           echo 'generator-settings={"biome":"plains","layers":[{"block":"bedrock","height":1},{"block":"dirt","height":3},{"block":"grass_block","height":1}]}' >> level-type.tmp ;;
        2) echo "level-type=FLAT" > level-type.tmp
           echo 'generator-settings={"layers":[]}' >> level-type.tmp ;;
        3) echo "level-type=AMPLIFIED" > level-type.tmp ;;
        4) echo "level-type=LARGEBIOMES" > level-type.tmp ;;
        5) read -p "Enter seed: " seed
           echo "level-seed=$seed" > level-type.tmp ;;
        6) [ -d ~/world_upload/world ] && cp -r ~/world_upload/* . || echo "No uploaded world found" ;;
    esac

    grep -v -E "^(level-type|generator-settings|level-seed)=" server.properties > server.properties.tmp 2>/dev/null || true
    cat level-type.tmp >> server.properties.tmp 2>/dev/null || true
    mv server.properties.tmp server.properties
    rm -f level-type.tmp
    echo "New world ready!"
    sleep 2
fi

clear
echo "Launching server in background (will survive SSH disconnects)..."
nohup /usr/lib/jvm/temurin-21-jdk-arm64/bin/java -Xmx20G -Xms20G -jar paper.jar nogui > server.log 2>&1 &
echo $! > minecraft.pid

sleep 8
echo "SERVER IS ONLINE!"
echo "Java: $IP:25565"
echo "Switch: $IP:19132 (DNS 104.238.130.180)"
echo
echo "Stop with: ./stop-minecraft.sh"
echo "View logs: tail -f server.log"
echo "Enjoy building with the kids!"
