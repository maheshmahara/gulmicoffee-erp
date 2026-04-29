#!/bin/bash
# ============================================================
# Gulmi Coffee — Full Odoo ERP Stack Setup
# Run from: ~/erp_work/gulmi-coffee/
# Usage:    bash setup-odoo.sh
# ============================================================
set -e

GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

echo -e "${GREEN}"
echo "  ╔══════════════════════════════════════════╗"
echo "  ║   Gulmi Coffee — Full Odoo ERP Setup     ║"
echo "  ║   PostgreSQL + Odoo 17 + Custom Frontend ║"
echo "  ╚══════════════════════════════════════════╝"
echo -e "${NC}"

# ── Step 1: Stop existing frontend container ──────────────────
echo -e "${YELLOW}[1/5] Stopping existing gulmi-erp container...${NC}"
cd ~/erp_work/gulmi-coffee/gulmicoffee-erp/gulmi-coffee-erp 2>/dev/null || true
docker compose down 2>/dev/null || true
echo "  Done."

# ── Step 2: Set up Odoo directory ─────────────────────────────
echo -e "${YELLOW}[2/5] Setting up Odoo stack directory...${NC}"
cd ~/erp_work/gulmi-coffee/
mkdir -p gulmi-odoo/{odoo-conf,addons/gulmi_coffee/{models,views,data,security,static/src/css,static/description},nginx,scripts,data}
echo "  Done."

# ── Step 3: Copy all odoo files ───────────────────────────────
echo -e "${YELLOW}[3/5] All config files should already be in gulmi-odoo/...${NC}"
echo "  Verify: ls ~/erp_work/gulmi-coffee/gulmi-odoo/"

# ── Step 4: Start the full stack ──────────────────────────────
echo -e "${YELLOW}[4/5] Starting full Odoo stack (this takes ~2 minutes)...${NC}"
cd ~/erp_work/gulmi-coffee/gulmi-odoo/
docker compose up -d

echo ""
echo -e "${YELLOW}Waiting for services to be healthy...${NC}"
sleep 15

# ── Step 5: Check status ──────────────────────────────────────
echo -e "${YELLOW}[5/5] Checking container status...${NC}"
docker compose ps

SERVER_IP=$(hostname -I | awk '{print $1}')

echo -e "${GREEN}"
echo "  ╔══════════════════════════════════════════════════════╗"
echo "  ║         Gulmi Coffee ERP Stack is UP!                ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  Custom Dashboard:  http://$SERVER_IP               ║"
echo "  ║  Odoo ERP:          http://$SERVER_IP/odoo          ║"
echo "  ║  Odoo direct:       http://$SERVER_IP:8069          ║"
echo "  ╠══════════════════════════════════════════════════════╣"
echo "  ║  Odoo Admin:        admin                            ║"
echo "  ║  Odoo Password:     GulmiAdmin@2025!                 ║"
echo "  ║  DB Name:           gulmi_erp                        ║"
echo "  ║  DB Password:       GulmiCoffee@2025!                ║"
echo "  ╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo "  First time? Odoo setup wizard will appear at :8069"
echo "  Use master password: GulmiAdmin@2025!"
echo ""
echo "  Logs: docker compose logs -f"
echo "  Stop: docker compose down"
