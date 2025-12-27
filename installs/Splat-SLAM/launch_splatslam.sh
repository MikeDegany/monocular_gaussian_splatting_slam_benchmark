#!/bin/bash
###############################################################################
# @file      launch_splatslam.sh
# @brief     Build, Start, and Enter the Splat-SLAM Docker environment
# @author    Mike Degany
# @email     mike.degany@gmail.com
# @date      2025-12-26
# @copyright Mike Degany. All rights reserved.
###############################################################################

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color (Reset)

# 1. Navigate to the directory where this script resides
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR" || { echo -e "${RED}✗ Failed to change directory to script location.${NC}"; exit 1; }

# Configuration
CONTAINER_NAME="splat-slam"

# 2. Build the image
echo -e "${YELLOW}Building Splat-SLAM Docker image...${NC}"
docker compose build

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to build Splat-SLAM Docker image.${NC}"
    exit 1
fi

# 3. Start the container in detached mode
echo -e "${YELLOW}Starting container...${NC}"
docker compose up -d

if [ $? -ne 0 ]; then
    echo -e "${RED}✗ Failed to start the container.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Splat-SLAM environment is up and running!${NC}"

# 4. Enter the container
if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
    echo -e "${YELLOW}Entering interactive shell...${NC}"
    echo "---------------------------------------------------------"
    docker exec -it "$CONTAINER_NAME" bash
else
    echo -e "${RED}✗ Container '$CONTAINER_NAME' is not running. Check logs with: docker compose logs${NC}"
    exit 1
fi