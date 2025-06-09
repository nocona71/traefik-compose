#!/bin/bash
set -e

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}Setting up Traefik Compose project...${NC}"

# Create directory structure
echo -e "${YELLOW}Creating directory structure...${NC}"
mkdir -p traefik/{config,data/auth} nginx/{config,html}

# Create network if it doesn't exist
echo -e "${YELLOW}Creating Docker network...${NC}"
docker network create web || true

# Copy example env files
echo -e "${YELLOW}Setting up environment files...${NC}"
cp -n nginx/.env.example nginx/.env || true
cp -n traefik/.env.example traefik/.env || true

# Create empty acme.json with correct permissions
echo -e "${YELLOW}Setting up SSL certificate storage...${NC}"
touch traefik/data/acme.json
chmod 600 traefik/data/acme.json

# Generate htpasswd file for Traefik dashboard
echo -e "${YELLOW}Setting up authentication...${NC}"
read -p "Enter Traefik dashboard username [admin]: " DASHBOARD_USER
DASHBOARD_USER=${DASHBOARD_USER:-admin}
read -s -p "Enter Traefik dashboard password: " DASHBOARD_PASSWORD
echo
htpasswd -bc traefik/data/auth/.htpasswd "$DASHBOARD_USER" "$DASHBOARD_PASSWORD"

# Create basic index.html
echo -e "${YELLOW}Creating default web page...${NC}"
cat > nginx/html/index.html <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome</title>
</head>
<body>
    <h1>Welcome to Traefik Compose</h1>
    <p>If you see this page, the Nginx web server is successfully installed.</p>
</body>
</html>
EOF

echo -e "${GREEN}Setup complete! Next steps:${NC}"
echo "1. Edit the .env files in nginx/ and traefik/ directories"
echo "2. Start Traefik: cd traefik && docker-compose up -d"
echo "3. Start Nginx: cd ../nginx && docker-compose up -d"

# Make the script executable
chmod +x setup.sh