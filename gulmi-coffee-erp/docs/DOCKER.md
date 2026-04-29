# Gulmi Coffee ERP & CRM — Docker Deployment Guide

> Deploy on any Ubuntu/Linux server in under 3 minutes using Docker.

---

## Quick Start

### Prerequisites

```bash
# Install Docker + Docker Compose on Ubuntu
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# Verify
docker --version        # Docker 24.x or higher
docker compose version  # Docker Compose v2.x
```

### One-Command Start

```bash
# Clone the repo
git clone https://github.com/maheshmahara/gulmicoffee-erp.git
cd gulmi-coffee-erp

# Copy environment file
cp .env.example .env

# Build and start
docker compose up -d

# Open browser
open http://localhost
```

---

## File Structure

```
gulmi-coffee-erp/
├── Dockerfile                  ← Docker image definition (nginx:alpine)
├── docker-compose.yml          ← Main compose file (development/staging)
├── docker-compose.prod.yml     ← Production override (SSL/HTTPS)
├── Makefile                    ← Shortcut commands
├── .env.example                ← Environment variable template
├── src/
│   └── index.html              ← ERP application (~2MB, self-contained)
└── docker/
    ├── nginx.conf              ← Nginx config (HTTP)
    ├── nginx-ssl.conf          ← Nginx config (HTTPS/SSL)
    └── healthcheck.html        ← Container health endpoint
```

---

## All Docker Commands

### Using Makefile (recommended)

```bash
make help       # Show all commands
make build      # Build image
make up         # Start containers
make down       # Stop containers
make restart    # Restart ERP container
make logs       # Follow logs
make shell      # Enter container shell
make update     # Rebuild + restart (after code changes)
make clean      # Remove everything (containers + volumes + images)
make ps         # Show running containers
make health     # Check if ERP is healthy
make prod       # Start with SSL (production)
```

### Using Docker Compose directly

```bash
# Build image
docker compose build

# Start (detached / background)
docker compose up -d

# Stop
docker compose down

# Follow logs
docker compose logs -f gulmi-erp

# Restart single service
docker compose restart gulmi-erp

# Rebuild and restart after file changes
docker compose up -d --build --force-recreate

# Show containers
docker compose ps

# Remove everything including volumes
docker compose down -v
```

### Using Docker directly

```bash
# Build image manually
docker build -t gulmi-coffee-erp:1.0 .

# Run container manually
docker run -d \
  --name gulmi-erp \
  --restart unless-stopped \
  -p 80:80 \
  -v $(pwd)/src/index.html:/usr/share/nginx/html/index.html:ro \
  gulmi-coffee-erp:1.0

# Enter running container
docker exec -it gulmi-erp /bin/sh

# View logs
docker logs -f gulmi-erp

# Stop and remove
docker stop gulmi-erp && docker rm gulmi-erp
```

---

## Configuration

### Environment Variables (`.env`)

```bash
# Copy and edit
cp .env.example .env
nano .env
```

| Variable | Default | Description |
|----------|---------|-------------|
| `ERP_PORT` | `80` | Host port to expose ERP on |
| `DOMAIN` | `erp.gulmicoffee.com.np` | Your domain (for SSL) |
| `TZ` | `Asia/Kathmandu` | Container timezone |

### Change the Port

```bash
# Run on port 8080 instead of 80
echo "ERP_PORT=8080" >> .env
docker compose up -d
# Access at http://localhost:8080
```

---

## Production Deployment with SSL (HTTPS)

### Step 1 — Point your domain DNS

Create an A record: `erp.gulmicoffee.com.np` → your server IP.
Wait for DNS propagation (1–30 minutes).

### Step 2 — Get SSL Certificate (Let's Encrypt)

```bash
# Set your domain
echo "DOMAIN=erp.gulmicoffee.com.np" > .env

# Get certificate (one-time)
docker run --rm \
  -p 80:80 \
  -v $(pwd)/ssl/certbot/conf:/etc/letsencrypt \
  -v $(pwd)/ssl/certbot/www:/var/www/certbot \
  certbot/certbot certonly \
  --standalone \
  -d erp.gulmicoffee.com.np \
  --email admin@gulmicoffee.com.np \
  --agree-tos \
  --non-interactive
```

### Step 3 — Start Production Stack

```bash
# Start with SSL
make prod
# or:
docker compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

This starts:
- `gulmi-erp` — ERP app on ports 80 + 443 with SSL
- `certbot` — auto-renews certificate every 12 hours
- `watchtower` — auto-updates container on new image

### Verify HTTPS

```bash
curl -I https://erp.gulmicoffee.com.np
# Should return HTTP/2 200
```

---

## Updating the ERP

### Option A — Live file update (no rebuild needed)

Since `index.html` is mounted as a volume, you can update without rebuilding:

```bash
# Replace the ERP HTML
cp new-version/index.html src/index.html

# Reload nginx (no downtime)
docker exec gulmi-erp nginx -s reload
```

### Option B — Full rebuild

```bash
make update
# or:
docker compose build --no-cache
docker compose up -d --force-recreate
```

---

## Logs & Monitoring

```bash
# Live application logs
make logs

# Nginx access log
docker exec gulmi-erp tail -f /var/log/nginx/gulmi-erp.access.log

# Nginx error log
docker exec gulmi-erp tail -f /var/log/nginx/gulmi-erp.error.log

# Container resource usage
docker stats gulmi-erp

# Health check status
make health
# or:
docker inspect --format='{{.State.Health.Status}}' gulmi-erp
```

---

## Backup

```bash
# Backup nginx logs (logs are in a named volume)
docker run --rm \
  -v gulmi-coffee-erp_gulmi_logs:/data \
  -v $(pwd)/backups:/backup \
  alpine tar czf /backup/gulmi-logs-$(date +%Y%m%d).tar.gz -C /data .

# Backup ERP source files
cp -r src/ backups/src-$(date +%Y%m%d)/
```

---

## Troubleshooting

### Container won't start
```bash
docker compose logs gulmi-erp
# Look for nginx config errors
docker exec gulmi-erp nginx -t
```

### Port 80 already in use
```bash
# Find what's using port 80
sudo lsof -i :80
# Or change port in .env
echo "ERP_PORT=8080" >> .env
docker compose up -d
```

### Health check failing
```bash
# Test health endpoint directly
curl http://localhost/health
# Should return HTML with "OK"
```

### Nginx config error after edit
```bash
# Validate nginx config inside container
docker exec gulmi-erp nginx -t
# If OK, reload
docker exec gulmi-erp nginx -s reload
```

### Reset everything
```bash
make clean
make build
make up
```

---

## Docker Image Details

| Property | Value |
|----------|-------|
| Base image | `nginx:alpine` |
| Final image size | ~25 MB |
| Exposed port | 80 |
| Restart policy | `unless-stopped` |
| Health check | Every 30s via HTTP GET /health |
| Timezone | Asia/Kathmandu |

---

## System Requirements

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| CPU | 1 core | 2 cores |
| RAM | 256 MB | 512 MB |
| Disk | 1 GB | 5 GB |
| OS | Ubuntu 20.04+ | Ubuntu 22.04 LTS |
| Docker | 20.x+ | 24.x+ |

---

*Gulmi Coffee ERP & CRM — Docker Edition*
*Version 1.0 | April 2025*
