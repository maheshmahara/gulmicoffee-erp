# Gulmi Coffee ERP & CRM System
### Complete Enterprise Resource Planning and Customer Relationship Management Platform

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Coffee Supply Chain Understanding](#2-coffee-supply-chain-understanding)
3. [System Architecture](#3-system-architecture)
4. [Module Reference](#4-module-reference)
5. [CRM & Invoicing Workflow](#5-crm--invoicing-workflow)
6. [Ubuntu Server Deployment](#6-ubuntu-server-deployment)
7. [File Structure](#7-file-structure)
8. [Configuration](#8-configuration)
9. [User Roles & Access](#9-user-roles--access)
10. [Git Repository Guide](#10-git-repository-guide)

---

## 1. Project Overview

**Gulmi Coffee ERP & CRM** is a full-stack enterprise management platform built specifically for Gulmi Coffee Pvt. Ltd., headquartered in Butwal, Lumbini Province, Nepal.

### Key Features

- Complete bean-to-cup supply chain tracking with real product imagery
- Inventory management across all 5 coffee processing stages
- Production scheduling with roast profiles
- Quality control with cupping score logging
- Distribution & shipment tracking across Nepal
- Financial management in NPR (Nepali Rupees)
- Full CRM: customers, leads pipeline, campaign management
- Customer-facing ordering portal for café/HoReCa buyers
- Loyalty tier system (Bronze / Silver / Gold / Platinum / Diamond)
- Designed for Ubuntu 22.04 / 24.04 LTS deployment with nginx

### Technology Stack

| Layer | Technology |
|-------|-----------|
| Frontend | HTML5, CSS3, Vanilla JavaScript |
| Charts | Chart.js 4.4.1 |
| Web Server | Nginx |
| OS | Ubuntu 22.04 LTS / 24.04 LTS |
| Currency | NPR (रू — Nepali Rupees) |
| Fonts | Playfair Display, DM Sans |

---

## 2. Coffee Supply Chain Understanding

The ERP system tracks Gulmi Coffee's product through all 5 processing stages. Understanding these stages is critical for correct inventory and quality management.

### Stage 1 — Fresh Cherry (Harvesting)

**What it is:** The raw coffee fruit as harvested from the tree. Bright red/crimson when fully ripe (as shown in `freshcherry.jpg`).

**In the ERP:**
- Sourced from: Gulmi Highlands Farm, Arghakhanchi Co-op, Palpa Mountain Growers
- Harvest season: October – December (Gulmi highlands)
- Moisture content at this stage: 60–65%
- Quality check: visual ripeness assessment, brix measurement
- Inventory location: Farm Storage / Collection Points

**Supply chain reference (from io Coffee diagram):**
> Step 1: Cultivation & Harvesting — Coffee plants are grown and cherries harvested when ripe.

### Stage 2 — Dry Cherry (Processing)

**What it is:** The coffee cherry after natural (dry) processing — sun-dried on raised beds for 3–6 weeks. The outer skin darkens to deep purple-brown (as shown in `Drycherry.png`). Internal fermentation imparts fruity, wine-like flavour notes.

**In the ERP:**
- Processing method: Natural (dry) — Gulmi's primary method
- Drying duration: 21–42 days
- Target moisture: 11–12%
- Quality risk: over-fermentation if not turned regularly
- Inventory location: Drying Beds / Warehouse A

**Supply chain reference:**
> Step 2: Processing — Cherries are processed to extract beans using dry or wet processing.

### Stage 3 — Parchment Bean (Milling)

**What it is:** After pulping/washing (wet process) or after dry processing and initial hulling, the bean is still enclosed in a papery parchment layer (the endocarp). Pale cream/wheat coloured with a visible central groove (as shown in `parchment1.png`).

**In the ERP:**
- Storage: Parchment is rested for 30–60 days (conditioning improves cup quality)
- Pre-hulling checks: moisture (target 11–12%), screen size, defect count
- Process: hulling machine removes parchment → polishing → grading
- Inventory location: Warehouse A / Conditioning Room

**Supply chain reference:**
> Step 3: Storage — Processed beans stored in conditions maintaining quality, away from moisture and direct sunlight.

### Stage 4 — Green Bean (Export / Storage)

**What it is:** The fully milled, unroasted coffee bean — olive-grey-green in colour (as shown in `GreenBean.png`). This is the internationally traded commodity form of coffee (green coffee).

**In the ERP:**
- Grading: screen size (Screen 14–18 for Gulmi Arabica), density sorting
- Quality standard: SCA specialty grade ≥ 80 cupping score
- Moisture: 10.5–12% (critical for shelf life and roast consistency)
- Storage: GrainPro bags inside jute sacks; Cold Room B at controlled humidity
- Shelf life: 12–18 months properly stored
- Inventory location: Cold Room B

**Supply chain reference:**
> Step 4: Transportation — Beans transported from storage to roasters, distributors, or export hubs.

### Stage 5 — Roasted Bean (Roasting & Packaging)

**What it is:** Green beans after drum roasting. The Maillard reaction and caramelisation transform bean chemistry, developing 800+ aroma compounds. No real image provided — Gulmi Coffee uses the following roast profiles:

| Profile | Temp Range | Colour | Use |
|---------|-----------|--------|-----|
| Light / Cinnamon | 195–205°C | Light brown | Specialty pour-over |
| City Roast (Medium) | 210–220°C | Medium brown | Espresso, filter |
| Full City | 225–230°C | Dark brown | Espresso, milk-based |
| Vienna Roast | 230–235°C | Dark | Espresso blend |

**In the ERP:**
- Batch tracking: B-XXXX series
- Post-roast: 12–24 hour degassing before packaging
- Packaging: nitrogen-flush in 250g / 500g valve bags
- Shelf life: 6–12 months sealed
- Inventory location: Dispatch Bay

---

## 3. System Architecture

```
gulmi-coffee-erp/
├── src/
│   └── index.html          ← Main ERP application (self-contained, ~2MB)
├── nginx/
│   └── gulmi-erp.conf      ← Nginx server configuration
├── scripts/
│   ├── deploy.sh           ← Automated Ubuntu deployment
│   └── git-init.sh         ← Git repository initialisation
├── docs/
│   └── README.md           ← This documentation file
└── assets/
    └── images.js           ← Base64 encoded product images (dev reference)
```

### How the Application Works

The ERP is a **single-page application (SPA)** delivered as one self-contained `index.html` file. All images (Fresh Cherry, Dry Cherry, Parchment, Green Bean) are base64-encoded and embedded directly in the HTML — no external image hosting required.

Page navigation is handled entirely in JavaScript by showing/hiding `<div class="page">` sections. No backend or database is required for the UI — this architecture makes it trivially simple to deploy on any Ubuntu server running nginx.

---

## 4. Module Reference

### Dashboard
Central overview showing real-time KPIs, bean-to-cup journey visual with clickable stage details using real product photos, revenue charts, inventory status, recent orders, and top customers.

### Supply Chain
Manages the complete procurement process from farm to facility:
- Supplier database with rating and status
- Purchase Order (PO) creation and tracking pipeline
- Integration with all 5 coffee stages (visualised with real imagery)

### Inventory
Full stock ledger tracking items across all processing stages:
- Stage tagging: Fresh Cherry / Dry Cherry / Parchment / Green Bean / Roasted
- Min level alerts with colour-coded status (Good / Low / Critical)
- Warehouse location tracking
- Expiry date management

### Production
Roasting and processing schedule management:
- Batch scheduling with roast profile assignment
- Line efficiency tracking per production unit
- Target vs actual performance monitoring

### Quality Control
SCA-aligned quality logging:
- Cupping score recording (pass threshold: 80+)
- Moisture % testing
- Defect count per batch
- Stage-specific testing (Green, Parchment, Roasted)

### Distribution
Nepal-specific shipment tracking:
- Route management (Butwal → Kathmandu / Pokhara / Biratnagar / Chitwan)
- Carrier integration (Nepal Fast Cargo, Lumbini Transport, National Carriers)
- On-time delivery KPIs

### Finance
Complete financial management in NPR:
- Revenue and COGS tracking
- Gross profit and margin calculation
- Cost breakdown (Raw Beans 42%, Labor 21%, Freight 12%, Packaging 9%, Utilities 8%, Overheads 8%)
- Transaction ledger with income/expense classification
- VAT (13%) calculation

### Orders
B2B order lifecycle management:
- Order creation and status tracking
- Fulfillment rate monitoring
- Average order value tracking

### CRM — Customers
Full customer relationship management:
- Tiered loyalty system: Bronze / Silver / Gold / Platinum / Diamond
- Lifetime value (LTV) tracking
- Customer type classification (HoReCa, Hotel, Roaster, Café, Retailer, Resort)
- Account manager assignment

### CRM — Leads
Sales pipeline management (inspired by Odoo CRM workflow):
- Stage tracking: Discovery → Proposal Sent → Negotiation → Won/Lost
- Lead source tracking (Referral, Trade Show, Cold Outreach, Website, Inbound)
- Pipeline value forecasting
- Sales rep assignment

### CRM — Campaigns
Marketing campaign management:
- Email and WhatsApp campaign creation
- Segment targeting by loyalty tier
- Open rate tracking
- Revenue attribution

### Customer Portal
B2B self-service ordering system for café/HoReCa customers:
- Secure login (email + password)
- Multi-account support with tier-based features (Platinum gets Net 30 credit, free freight)
- Product catalogue with real images
- 4-step checkout: Cart → Delivery → Payment → Confirmation
- Payment methods: Net 30 Credit, Bank Transfer, eSewa/Khalti, Cash on Delivery
- Order history with one-click reorder
- Loyalty points and tier progression display

---

## 5. CRM & Invoicing Workflow

Based on the Odoo 19 CRM to invoicing workflow principles, the Gulmi Coffee ERP follows this complete cycle:

```
Lead Created
     ↓
Discovery Call / Meeting Logged
     ↓
Proposal Sent (with product catalogue & pricing)
     ↓
Negotiation (quantity, pricing, payment terms)
     ↓
Deal Won → Customer Record Created
     ↓
Sales Order (SO) Created
     ↓
Production / Inventory Allocation
     ↓
Quality Check Passed
     ↓
Dispatch & Shipment Created
     ↓
Delivery Confirmed
     ↓
Invoice Generated (with VAT 13%)
     ↓
Payment Received (Bank / eSewa / Khalti / Credit)
     ↓
CRM: Loyalty Points Awarded → Tier Review
     ↓
Campaign: Post-purchase follow-up email/WhatsApp
```

### Key CRM Concepts (Odoo-aligned)

**Lead to Opportunity:** When a café or hotel expresses interest, a lead is created in the Leads module with estimated annual value. Once qualified, it becomes an opportunity with a stage.

**Customer Tiers:** Based on annual spend:
- Bronze: 0 – रू 50,000/yr
- Silver: रू 50,001 – रू 150,000/yr
- Gold: रू 150,001 – रू 300,000/yr
- Platinum: रू 300,001 – रू 600,000/yr
- Diamond: रू 600,001+/yr

**Invoicing Terms by Tier:**
- Bronze/Silver: Cash on Delivery or advance payment
- Gold: Net 15 (pay within 15 days of delivery)
- Platinum: Net 30 (pay within 30 days)
- Diamond: Net 45 + dedicated account manager

---

## 6. Ubuntu Server Deployment

### Prerequisites

- Ubuntu 22.04 LTS or 24.04 LTS
- Minimum: 1 vCPU, 512MB RAM, 2GB storage
- Root or sudo access

### Quick Deployment (5 minutes)

```bash
# 1. Clone or upload the project
git clone https://github.com/maheshmahara/gulmicoffee-erp.git
cd gulmi-coffee-erp

# 2. Run deployment script
sudo bash scripts/deploy.sh

# 3. Open browser
# http://YOUR_SERVER_IP
```

### Manual Step-by-Step Deployment

```bash
# Step 1: Install nginx
sudo apt update
sudo apt install -y nginx

# Step 2: Create web directory
sudo mkdir -p /var/www/gulmi-erp

# Step 3: Copy ERP files
sudo cp src/index.html /var/www/gulmi-erp/
sudo chown -R www-data:www-data /var/www/gulmi-erp
sudo chmod -R 755 /var/www/gulmi-erp

# Step 4: Configure nginx
sudo cp nginx/gulmi-erp.conf /etc/nginx/sites-available/gulmi-erp
sudo ln -s /etc/nginx/sites-available/gulmi-erp /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx

# Step 5: Enable firewall (optional but recommended)
sudo ufw allow 'Nginx Full'
sudo ufw allow OpenSSH
sudo ufw enable

# Step 6: Access the system
echo "Open http://$(hostname -I | awk '{print $1}') in your browser"
```

### Custom Domain Setup

To use a custom domain (e.g., `erp.gulmicoffee.com.np`):

```bash
# Edit nginx config
sudo nano /etc/nginx/sites-available/gulmi-erp

# Change:
server_name gulmi-erp.local;
# To:
server_name erp.gulmicoffee.com.np;

# Reload nginx
sudo nginx -t && sudo systemctl reload nginx
```

### SSL/HTTPS with Let's Encrypt (recommended for production)

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d erp.gulmicoffee.com.np
```

### Nginx Configuration File

Location: `nginx/gulmi-erp.conf`

```nginx
server {
    listen 80;
    server_name gulmi-erp.local;
    root /var/www/gulmi-erp;
    index index.html;

    gzip on;
    gzip_types text/html text/css application/javascript;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location ~* \.(js|css|png|jpg)$ {
        expires 30d;
        add_header Cache-Control "public, max-age=2592000";
    }
}
```

### Useful Commands

```bash
# Check nginx status
sudo systemctl status nginx

# Restart nginx
sudo systemctl restart nginx

# View access logs
sudo tail -f /var/log/nginx/gulmi-erp.access.log

# View error logs
sudo tail -f /var/log/nginx/gulmi-erp.error.log

# Update ERP files
sudo cp src/index.html /var/www/gulmi-erp/
sudo systemctl reload nginx
```

---

## 7. File Structure

```
gulmi-coffee-erp/
├── README.md                   ← This documentation
├── src/
│   └── index.html              ← Complete ERP system (~2MB, self-contained)
│                                  Includes: all modules, charts, real product images
│                                  embedded as base64, Chart.js from CDN
├── nginx/
│   └── gulmi-erp.conf          ← Nginx virtual host configuration
├── scripts/
│   ├── deploy.sh               ← Full automated deployment for Ubuntu
│   └── git-init.sh             ← Initialise and push git repository
├── docs/
│   └── README.md               ← Full documentation (this file)
└── assets/
    ├── images.js               ← Base64 image data (dev reference)
    └── img_data.py             ← Python helper to regenerate images.js
```

---

## 8. Configuration

### Currency

The system uses **NPR (Nepali Rupees, रू)** throughout. All financial figures are in लाख (Lakh = 100,000 रू).

### Fiscal Year

Nepal's fiscal year starts in **Shrawan** (mid-July). The settings module allows switching between Nepali and Gregorian fiscal year reporting.

### VAT

Nepal VAT is 13%. The checkout and invoice modules automatically calculate and display VAT-inclusive totals.

---

## 9. User Roles & Access

| Role | Modules Access | User |
|------|--------------|------|
| Admin (GM) | All modules | General Manager |
| Quality Manager | Quality Control, Production, Inventory | Sita Rana |
| Production Lead | Production, Inventory, Quality | Ram KC |
| Sales Manager | CRM, Orders, Distribution, Customers, Leads | Suresh BK |
| CRM Executive | Customers, Leads, Campaigns, Orders | Nisha KC |

### Customer Portal Users (B2B)

| Login | Password | Tier | Notes |
|-------|----------|------|-------|
| himalayan@cafe.np | 1234 | Platinum | Demo: Himalayan Café |
| hotel@annapurna.np | 1234 | Gold | Demo: Hotel Annapurna |
| pokhara@brew.np | 1234 | Silver | Demo: Pokhara Brew Co. |

---

## 10. Git Repository Guide

### Initial Setup

```bash
# Navigate to project folder
cd gulmi-coffee-erp

# Initialise git
bash scripts/git-init.sh

# Add GitHub remote (replace with your GitHub username)
git remote add origin https://github.com/maheshmahara/gulmicoffee-erp.git
git branch -M main
git push -u origin main
```

### Recommended `.gitignore`

```
assets/img_data.py
assets/images.js
node_modules/
*.log
.env
```

### Commit Message Convention

```
feat: add new module
fix: correct inventory calculation
docs: update README deployment section
style: adjust dashboard layout
chore: update deployment script
```

### Branch Strategy

```
main          ← production-ready code
dev           ← active development
feature/xxx   ← new feature branches
hotfix/xxx    ← urgent production fixes
```

### Example Workflow

```bash
# Start a new feature
git checkout -b feature/customer-invoicing
# ... make changes ...
git add .
git commit -m "feat: add invoice PDF generation to customer portal"
git push origin feature/customer-invoicing
# Create Pull Request on GitHub → merge to dev → merge to main
```

---

## Appendix: Coffee Supply Chain Reference (io Coffee, 10-Step Model)

The supply chain infographic provided maps to Gulmi Coffee's process as follows:

| io Coffee Step | Gulmi Coffee Process | ERP Module |
|---------------|---------------------|------------|
| 1. Cultivation & Harvesting | Cherry picking at Gulmi farms | Supply Chain → Suppliers |
| 2. Processing | Dry/natural processing | Inventory (Dry Cherry stage) |
| 3. Storage | Parchment conditioning | Inventory (Parchment stage) |
| 4. Transportation | Road transport Gulmi → Butwal | Distribution |
| 5. Roasting | Drum roasting at Butwal facility | Production |
| 6. Packaging | Nitrogen-flush 250g/500g bags | Production |
| 7. Distribution | Nepal-wide delivery network | Distribution |
| 8. Retailing | B2B cafés, hotels, roasters | Customer Portal / Orders |
| 9. Consumption | End customer / café brewing | — |
| 10. Feedback | Quality feedback loop | Quality Control |

---

*Gulmi Coffee ERP & CRM — Built for Gulmi Coffee Pvt. Ltd., Butwal, Nepal*
*Version 1.0 | April 2025*
