#!/bin/bash
set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Setting up Traefik configuration...${NC}"

# Create network if it doesn't exist
NETWORK_NAME=${TRAEFIK_NETWORK:-web}
if ! docker network ls | grep -q $NETWORK_NAME; then
    echo -e "${YELLOW}Creating Docker network: $NETWORK_NAME${NC}"
    docker network create $NETWORK_NAME
fi

# Create .env if it doesn't exist
if [ ! -f .env ]; then
    echo -e "${YELLOW}Creating .env file from template...${NC}"
    cp .env.example .env
    echo "Please edit .env with your settings"
fi

# Initialize acme.json
if [ ! -f acme.json ]; then
    echo -e "${YELLOW}Creating acme.json...${NC}"
    touch acme.json
    chmod 600 acme.json
fi

# Create auth directory and generate htpasswd file
mkdir -p auth
if [ ! -f auth/.htpasswd ]; then
    echo -e "${YELLOW}Generating authentication credentials...${NC}"
    read -p "Enter username for dashboard access [admin]: " USERNAME
    USERNAME=${USERNAME:-admin}
    read -s -p "Enter password for dashboard access: " PASSWORD
    echo
    htpasswd -bc auth/.htpasswd $USERNAME $PASSWORD
    chmod 600 auth/.htpasswd
fi

echo -e "${GREEN}Setup complete!${NC}"
echo -e "Next steps:"
echo -e "1. Edit .env file with your settings"
echo -e "2. Run: docker-compose up -d"