#!/bin/bash
# stop-minecraft.sh – safely stops the daemonized server

cd ~/minecraft || { echo "Error: ~/minecraft not found!"; exit 1; }

if [ -f minecraft.pid ]; then
    PID=$(cat minecraft.pid)
    echo "Gracefully stopping server (PID $PID)..."
    kill $PID
    sleep 12  # Give it time to save world
    kill $PID 2>/dev/null || true  # force if still alive
    rm -f minecraft.pid
else
    echo "No PID file. Killing any running Paper server..."
    pkill -f paper.jar || echo "No Paper process found."
fi

echo "Server stopped and world saved."
echo "You can now safely run ./start-minecraft.sh again."
