# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Traefik-based Docker Compose setup for hosting multiple services as subdomains with automatic SSL certificate management. The architecture uses:

- **Traefik v2.10** as a reverse proxy and load balancer with automatic Let's Encrypt SSL
- **Nginx** as a web server example
- **Docker networks** (`web`) to connect services
- **Environment-based configuration** for different domains and settings

## Key Commands

### Initial Setup
```bash
./setup.sh
```
This script creates the directory structure, Docker network, authentication files, and default configurations.

### Starting Services
```bash
# Start Traefik (must be started first)
cd traefik && docker-compose up -d

# Start Nginx or other services
cd nginx && docker-compose up -d
```

### Managing Services
```bash
# View logs
docker-compose logs -f [service_name]

# Stop services
docker-compose down

# Rebuild and restart
docker-compose up -d --build
```

### SSL Certificate Management
```bash
# Check certificate status
docker exec traefik_proxy cat /acme.json

# Reset certificates (if needed)
docker-compose down
rm traefik/data/acme.json && touch traefik/data/acme.json && chmod 600 traefik/data/acme.json
docker-compose up -d
```

## Architecture

### Network Structure
- All services connect to the external `web` Docker network
- Traefik acts as the gateway, routing traffic based on Host rules
- Services are accessed via subdomains (e.g., `traefik.example.com`, `www.example.com`)

### Configuration Pattern
Services follow this pattern:
1. **Global environment file** (`/.env`) defines shared settings like TLD, TZ, and common credentials
2. **Service-specific environment files** (`service/.env`) define only service-specific settings like SLD
3. **Docker Compose labels** configure Traefik routing rules
4. **Config files** in service directories handle application-specific configuration

#### Environment Variable Inheritance
- Global variables (TLD, TZ, shared credentials) are defined in the root `.env` file
- Service-specific variables (SLD, database names, etc.) are in service `.env` files
- Docker Compose automatically merges both files, with service-specific taking precedence

### Adding New Services
When adding a new service:
1. Create a new directory with `docker-compose.yaml`
2. Add appropriate Traefik labels for routing
3. Connect to the `web` network
4. Configure subdomain via `TLD` environment variable

### Key Files
- `traefik/config/traefik.yaml`: Main Traefik configuration
- `traefik/data/acme.json`: SSL certificate storage (must have 600 permissions)
- `traefik/data/auth/.htpasswd`: Dashboard authentication
- Environment files control domain routing and service configuration