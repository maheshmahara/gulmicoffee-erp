#!/bin/bash
# =============================================================
# Gulmi Coffee ERP & CRM — Ubuntu Server Deployment Script
# Tested on Ubuntu 22.04 LTS / 24.04 LTS
# Run as: sudo bash deploy.sh
# =============================================================

set -e

DEPLOY_DIR="/var/www/gulmi-erp"
NGINX_CONF="/etc/nginx/sites-available/gulmi-erp"
REPO_URL="https://github.com/maheshmahara/gulmicoffee-erp.git"  # update this
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}==> Gulmi Coffee ERP Deployment Starting...${NC}"

# 1. Update system
echo -e "${YELLOW}[1/7] Updating system packages...${NC}"
apt-get update -qq
apt-get install -y nginx git curl ufw

# 2. Create web directory
echo -e "${YELLOW}[2/7] Setting up web directory...${NC}"
mkdir -p "$DEPLOY_DIR"

# 3. Copy files
echo -e "${YELLOW}[3/7] Copying ERP files...${NC}"
cp -r src/* "$DEPLOY_DIR/"
chown -R www-data:www-data "$DEPLOY_DIR"
chmod -R 755 "$DEPLOY_DIR"

# 4. Configure nginx
echo -e "${YELLOW}[4/7] Configuring nginx...${NC}"
cp nginx/gulmi-erp.conf "$NGINX_CONF"
ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/gulmi-erp
nginx -t && systemctl reload nginx

# 5. Firewall
echo -e "${YELLOW}[5/7] Configuring firewall...${NC}"
ufw allow 'Nginx Full'
ufw allow OpenSSH
ufw --force enable

# 6. Enable nginx on boot
echo -e "${YELLOW}[6/7] Enabling nginx on startup...${NC}"
systemctl enable nginx

# 7. Done
SERVER_IP=$(hostname -I | awk '{print $1}')
echo -e "${GREEN}"
echo "=============================================="
echo " Gulmi Coffee ERP deployed successfully!"
echo " URL: http://$SERVER_IP"
echo " Files: $DEPLOY_DIR"
echo " Nginx config: $NGINX_CONF"
echo "=============================================="
echo -e "${NC}"
