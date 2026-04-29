#!/bin/bash
# Initialise git and push to your GitHub repo
# Usage: bash scripts/git-init.sh
# IMPORTANT: You need a GitHub Personal Access Token (PAT)
# Get one at: https://github.com/settings/tokens (scopes: repo)

set -e

REPO_URL="https://github.com/maheshmahara/gulmicoffee-erp.git"

echo "==> Initialising Gulmi Coffee ERP git repository..."

git init
git add .
git commit -m "feat: Gulmi Coffee ERP & CRM System v1.0

Complete ERP & CRM system for Gulmi Coffee Pvt. Ltd., Butwal Nepal.

Modules:
- Dashboard with bean-to-cup journey (real product images)
- Supply Chain: suppliers, purchase orders, procurement pipeline
- Inventory: 5-stage tracking (Cherry → Dry → Parchment → Green → Roasted)
- Production: batch scheduling, roast profiles, line efficiency
- Quality Control: cupping scores, moisture, defect logging
- Distribution: shipment tracking across Nepal routes
- Finance: P&L, cost breakdown, transactions in NPR
- Orders: B2B order lifecycle management
- CRM: Customers, Leads pipeline, Campaigns
- Customer Portal: café/hotel ordering with loyalty tiers

Infrastructure:
- Docker: Dockerfile (nginx:alpine), docker-compose.yml, SSL support
- Nginx: optimised config with gzip, security headers, health check
- Makefile: shortcut commands (make up/down/logs/update/prod)
- Ubuntu deployment script
- Full documentation (docs/README.md, docs/DOCKER.md)"

git remote add origin $REPO_URL
git branch -M main
git push -u origin main

echo ""
echo "✓ Successfully pushed to: $REPO_URL"
echo "  View at: https://github.com/maheshmahara/gulmicoffee-erp"
