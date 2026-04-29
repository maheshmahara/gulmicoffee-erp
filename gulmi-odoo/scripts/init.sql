-- ============================================================
-- Gulmi Coffee ERP — PostgreSQL Initial Data
-- Source: coffee_automated_accounting_costing_system.xlsx
-- ============================================================

-- Coffee Processing Stages
CREATE TABLE IF NOT EXISTS coffee_stages (
    id          SERIAL PRIMARY KEY,
    code        VARCHAR(20) UNIQUE NOT NULL,
    name        VARCHAR(100) NOT NULL,
    sequence    INTEGER,
    description TEXT
);

INSERT INTO coffee_stages (code, name, sequence, description) VALUES
('FRESH',     'Fresh Cherry',    1, 'Raw harvested coffee cherry. Moisture ~60-65%. Selective red-ripe picking.'),
('DRY',       'Dry Cherry',      2, 'Sun-dried cherry. Natural processing 3-6 weeks. Moisture target 11-12%.'),
('PARCHMENT', 'Parchment Bean',  3, 'Bean in endocarp/parchment layer. Rested 30-60 days before hulling.'),
('GREEN',     'Green Bean',      4, 'Milled unroasted bean. Export-ready. Moisture 10.5-12%. Graded by screen.'),
('ROASTED',   'Roasted Bean',    5, 'Drum roasted. 800+ aroma compounds developed. Packaged nitrogen-flush.')
ON CONFLICT (code) DO NOTHING;

-- ── Costing Inputs (from Excel Inputs sheet) ─────────────────
CREATE TABLE IF NOT EXISTS costing_inputs (
    id              SERIAL PRIMARY KEY,
    parameter       VARCHAR(200) NOT NULL,
    value           NUMERIC(12,4),
    unit            VARCHAR(50),
    description     TEXT,
    source_note     VARCHAR(200),
    updated_at      TIMESTAMP DEFAULT NOW()
);

INSERT INTO costing_inputs (parameter, value, unit, description, source_note) VALUES
-- Volumes & Purchase Prices
('fresh_cherry_qty',          1,      'kg',       'Raw fresh cherry purchased',        'User input'),
('fresh_cherry_price',        500,    'Rs/kg',     'Procurement rate fresh cherry',     'User input'),
('dry_cherry_qty',            100,    'kg',       'Dry cherry purchased',              'User input / placeholder'),
('dry_cherry_price',          400,    'Rs/kg',     'Procurement rate dry cherry',       'Editable assumption'),
('parchment_qty',             300,    'kg',       'Parchment purchased',               'User input / placeholder'),
('parchment_price',           830,    'Rs/kg',     'Procurement rate parchment',        'User input'),
('green_bean_qty',            500,    'kg',       'Green beans purchased',             'Editable assumption'),
('green_bean_price',          1900,   'Rs/kg',     'Procurement rate green beans',      'Editable assumption'),
-- Yield Assumptions
('fresh_to_parchment_yield',  0.50,   '%',        'Parchment output / fresh cherry',   'Editable assumption'),
('dry_to_green_yield',        0.80,   '%',        'Green output / dry cherry',         'Editable assumption'),
('parchment_to_green_yield',  0.75,   '%',        'Green output / parchment',          'User input'),
('green_to_roasted_yield',    0.85,   '%',        'Roasted output / green',            'User input'),
('cups_per_kg_roasted',       50,     'cups/kg',  'Based on dose size',                'Editable assumption'),
-- Processing Costs
('transport_per_kg',          30,     'Rs/kg',     'Village to factory freight',        'Per kg input'),
('fresh_processing_per_kg',   20,     'Rs/kg',     'Pulping/washing/drying cost',      'Per kg fresh cherry'),
('dry_cleaning_per_kg',       10,     'Rs/kg',     'Dry cherry cleaning/sorting',      'Per kg dry cherry'),
('hulling_electricity_per_kg',25,     'Rs/kg',     'Hulling electricity per kg parchment','Per kg parchment'),
('hulling_labour_per_kg',     10,     'Rs/kg',     'Hulling labour per kg parchment',  'Per kg parchment'),
('roasting_electricity_per_kg',25,    'Rs/kg',     'Roasting electricity per kg green','Per kg green'),
('roasting_labour_per_kg',    10,     'Rs/kg',     'Roasting labour per kg green',     'Per kg green'),
('packaging_per_kg_roasted',  60,     'Rs/kg',     'Coffee bags/labels/sealing',       'Per kg roasted'),
('cafe_variable_per_cup',     30,     'Rs/cup',    'Milk/sugar/syrups per cup',        'Per cup'),
('cup_selling_price',         130,    'Rs/cup',    'Retail cup selling price',         'User input'),
('annual_fixed_cost',         416000, 'Rs/year',   'Annual fixed cost all sources',    'Shared fixed cost')
ON CONFLICT DO NOTHING;

-- ── Chart of Accounts Map (from Excel Accounts_Map sheet) ────
CREATE TABLE IF NOT EXISTS chart_of_accounts (
    id              SERIAL PRIMARY KEY,
    main_title      VARCHAR(200),
    sub_title       VARCHAR(200),
    gl_group        VARCHAR(100),
    notes           TEXT
);

INSERT INTO chart_of_accounts (main_title, sub_title, gl_group, notes) VALUES
('Fresh Cherry Procurement',  'Purchase cost per kg',              'COGS - Raw Material',       'Use when buying fresh cherry'),
('Fresh Cherry Procurement',  'Farmer payment / collection commission', 'COGS - Raw Material',  'Optional'),
('Fresh Cherry Procurement',  'Sorting / source loss',             'COGS - Processing loss',    'Optional'),
('Dry Cherry Procurement',    'Purchase cost',                     'COGS - Raw Material',       'Use when buying dry cherry'),
('Dry Cherry Procurement',    'Drying loss adjustment',            'COGS - Yield adjustment',   'Optional'),
('Parchment Procurement',     'Purchase cost',                     'COGS - Raw Material',       'Use when buying parchment'),
('Parchment Procurement',     'Quality grading / moisture adjustment','COGS - Yield adjustment','Optional'),
('Green Bean Procurement',    'Purchase cost',                     'COGS - Raw Material',       'Use when buying green beans'),
('Inbound Transport',         'Village to factory freight',        'COGS - Logistics',          'Per kg input'),
('Inbound Transport',         'Loading / unloading',               'COGS - Logistics',          'Optional'),
('Processing',                'Fresh cherry pulping / washing / drying','COGS - Processing',   'Per kg fresh cherry'),
('Processing',                'Dry cherry cleaning / sorting',     'COGS - Processing',         'Per kg dry cherry'),
('Hulling',                   'Electricity',                       'COGS - Utilities',          'Per kg parchment'),
('Hulling',                   'Labour',                            'COGS - Labour',             'Per kg parchment'),
('Roasting',                  'Electricity',                       'COGS - Utilities',          'Per kg green'),
('Roasting',                  'Labour',                            'COGS - Labour',             'Per kg green'),
('Packaging',                 'Coffee bags / labels / sealing',    'COGS - Packaging',          'Per kg roasted'),
('Café Variable',             'Milk / sugar / syrups',             'COGS - Café consumables',   'Per cup'),
('Café Fixed',                'Rent / utilities / salaries',       'Fixed Overhead',            'Annual fixed cost'),
('Sales Revenue',             'Cup sales',                         'Revenue - Café',            'Per cup × price'),
('Sales Revenue',             'Bulk roasted bean sales',           'Revenue - B2B',             'Per kg × wholesale price')
ON CONFLICT DO NOTHING;

-- ── Costing Summary (pre-calculated from Excel Summary_Compare) ──
CREATE TABLE IF NOT EXISTS costing_summary (
    id                      SERIAL PRIMARY KEY,
    source                  VARCHAR(50) NOT NULL,
    input_qty_kg            NUMERIC(12,4),
    roasted_output_kg       NUMERIC(12,4),
    cups_produced           NUMERIC(12,4),
    total_variable_cost_rs  NUMERIC(14,2),
    cost_per_roasted_kg     NUMERIC(12,4),
    coffee_cost_per_cup     NUMERIC(12,4),
    cup_sales_revenue       NUMERIC(14,2),
    contribution_before_fixed NUMERIC(14,2),
    annual_fixed_cost       NUMERIC(14,2),
    net_profit              NUMERIC(14,2),
    net_margin_pct          NUMERIC(8,4),
    breakeven_cups_per_day  NUMERIC(10,4),
    updated_at              TIMESTAMP DEFAULT NOW()
);

INSERT INTO costing_summary
  (source, input_qty_kg, roasted_output_kg, cups_produced, total_variable_cost_rs,
   cost_per_roasted_kg, coffee_cost_per_cup, cup_sales_revenue,
   contribution_before_fixed, annual_fixed_cost, net_profit, net_margin_pct, breakeven_cups_per_day)
VALUES
('Fresh Cherry', 1,    0.31875,  15.9375,  599.75,     1881.57, 37.63,  2071.88,    994.00,   416000, -415006, -200.30, 18.27),
('Dry Cherry',   100,  68,       3400,     50880,       748.24, 14.96,  442000,     289120,   416000, -126880,   -0.29, 13.40),
('Parchment',    300,  191.25,   9562.5,   287850,     1505.10, 30.10,  1243125,    668400,   416000,  252400,    0.20, 16.31),
('Green Beans',  500,  425,      21250,    1008000,    2371.76, 47.44,  2762500,   1117000,   416000,  701000,    0.25, 21.68)
ON CONFLICT DO NOTHING;

-- ── Suppliers ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS suppliers (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(200) NOT NULL,
    region      VARCHAR(100),
    bean_type   VARCHAR(50),
    rating      SMALLINT CHECK (rating BETWEEN 1 AND 5),
    stage_code  VARCHAR(20) REFERENCES coffee_stages(code),
    phone       VARCHAR(30),
    status      VARCHAR(20) DEFAULT 'active',
    created_at  TIMESTAMP DEFAULT NOW()
);

INSERT INTO suppliers (name, region, bean_type, rating, stage_code, phone, status) VALUES
('Gulmi Highlands Farm',    'Gulmi District',  'Arabica',   5, 'FRESH',     '+977-9841-111001', 'active'),
('Arghakhanchi Co-op',      'Arghakhanchi',    'Robusta',   4, 'FRESH',     '+977-9841-222002', 'active'),
('Palpa Mountain Growers',  'Palpa',           'Specialty', 5, 'DRY',       '+977-9841-333003', 'review'),
('Syangja Organic Farms',   'Syangja',         'Arabica',   3, 'GREEN',     '+977-9841-444004', 'inactive'),
('Gulmi Dry Cherry Co-op',  'Gulmi District',  'Arabica',   4, 'DRY',       '+977-9841-555005', 'active'),
('Rukum Parchment Hub',     'Rukum',           'Robusta',   4, 'PARCHMENT', '+977-9841-666006', 'active')
ON CONFLICT DO NOTHING;

-- ── Customers ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS customers (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(200) NOT NULL,
    business_type   VARCHAR(50),
    city            VARCHAR(100),
    contact_person  VARCHAR(100),
    phone           VARCHAR(30),
    email           VARCHAR(100),
    tier            VARCHAR(20) DEFAULT 'silver',
    loyalty_points  INTEGER DEFAULT 0,
    annual_spend    NUMERIC(14,2) DEFAULT 0,
    created_at      TIMESTAMP DEFAULT NOW()
);

INSERT INTO customers (name, business_type, city, contact_person, phone, email, tier, loyalty_points, annual_spend) VALUES
('Himalayan Café',       'HoReCa',   'Kathmandu',  'Ram Shrestha',  '+977-9841-100001', 'himalayan@cafe.np',       'platinum', 4820, 480000),
('Hotel Annapurna',      'Hotel',    'Pokhara',    'Maya Gurung',   '+977-9841-200002', 'hotel@annapurna.np',      'gold',     2140, 320000),
('Kathmandu Roasters',   'Roaster',  'Kathmandu',  'Bikash Tamang', '+977-9841-300003', 'info@ktmroasters.np',     'gold',     1980, 290000),
('Pokhara Brew Co.',     'Café',     'Pokhara',    'Sunita Magar',  '+977-9841-400004', 'pokhara@brew.np',         'silver',   870,  170000),
('Chitwan Estates',      'Resort',   'Chitwan',    'Anil Thapa',    '+977-9841-500005', 'info@chitwanestates.np',  'silver',   620,  120000),
('Biratnagar Naturals',  'Retailer', 'Biratnagar', 'Priya Shah',    '+977-9841-600006', 'biratnagar@naturals.np',  'silver',   540,  140000),
('Lumbini Retreat',      'Hotel',    'Lumbini',    'Deepak Rai',    '+977-9841-700007', 'info@lumbiniretreat.np',  'bronze',   120,  60000),
('Everest Base Lodge',   'Hotel',    'Solukhumbu', 'Kaji Sherpa',   '+977-9841-800008', 'info@everestlodge.np',    'bronze',   80,   40000)
ON CONFLICT DO NOTHING;

-- ── Products ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS products (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(200) NOT NULL,
    stage_code      VARCHAR(20) REFERENCES coffee_stages(code),
    price_per_kg    NUMERIC(10,2),
    unit            VARCHAR(20) DEFAULT 'kg',
    stock_kg        NUMERIC(12,3),
    min_stock_kg    NUMERIC(12,3),
    description     TEXT,
    active          BOOLEAN DEFAULT TRUE
);

INSERT INTO products (name, stage_code, price_per_kg, stock_kg, min_stock_kg, description) VALUES
('Gulmi Arabica Medium Roast',    'ROASTED',   840,  1100, 400, 'City roast, balanced cup, 86+ SCA score'),
('Robusta Dark Blend',            'ROASTED',   720,   560, 200, 'Full city roast, strong, low acidity'),
('Gulmi Specialty Light Roast',   'ROASTED',  1600,   180, 200, 'Light/cinnamon roast, 89+ SCA, floral notes'),
('Espresso Vienna Blend',         'ROASTED',   900,   420, 200, 'Vienna roast, espresso profile'),
('Arabica Green Bean',            'GREEN',     680,  1840, 500, 'Screen 15-17, moisture 11.2%, specialty grade'),
('Robusta Green Bean',            'GREEN',     580,   920, 300, 'Screen 14-16, moisture 11.8%'),
('Monsoon Harvest Blend',         'ROASTED',  1400,   160, 100, 'Limited batch, seasonal specialty'),
('Arabica Parchment',             'PARCHMENT', 830,   640, 200, 'Post-wash conditioned parchment'),
('Gulmi Arabica Fresh Cherry',    'FRESH',     500,  2400,   0, 'Selective red-ripe, Oct-Dec harvest')
ON CONFLICT DO NOTHING;

-- ── Production Batches ────────────────────────────────────────
CREATE TABLE IF NOT EXISTS production_batches (
    id              SERIAL PRIMARY KEY,
    batch_id        VARCHAR(20) UNIQUE NOT NULL,
    product_name    VARCHAR(200),
    input_stage     VARCHAR(20) REFERENCES coffee_stages(code),
    input_qty_kg    NUMERIC(12,3),
    output_qty_kg   NUMERIC(12,3),
    roast_profile   VARCHAR(50),
    scheduled_at    TIMESTAMP,
    completed_at    TIMESTAMP,
    status          VARCHAR(20) DEFAULT 'planned',
    operator        VARCHAR(100),
    notes           TEXT
);

INSERT INTO production_batches (batch_id, product_name, input_stage, input_qty_kg, output_qty_kg, roast_profile, scheduled_at, status, operator) VALUES
('B-0841', 'Arabica Medium Roast', 'GREEN', 235.3, 200.0, 'City Roast',      NOW() - INTERVAL '1 day',  'completed', 'Ram KC'),
('B-0842', 'Robusta Dark',        'GREEN', 176.5, 150.0, 'Full City',       NOW(),                     'in_progress','Ram KC'),
('B-0843', 'Specialty Light',     'GREEN',  94.1,  80.0, 'Light/Cinnamon',  NOW() + INTERVAL '1 day',  'scheduled', 'Sita Rana'),
('B-0844', 'Espresso Blend',      'GREEN', 352.9, 300.0, 'Vienna Roast',    NOW() + INTERVAL '2 days', 'planned',   'Ram KC')
ON CONFLICT (batch_id) DO NOTHING;

-- ── Quality Control ───────────────────────────────────────────
CREATE TABLE IF NOT EXISTS quality_tests (
    id              SERIAL PRIMARY KEY,
    batch_id        VARCHAR(20),
    stage_code      VARCHAR(20) REFERENCES coffee_stages(code),
    product_name    VARCHAR(200),
    test_type       VARCHAR(50),
    cupping_score   NUMERIC(5,2),
    moisture_pct    NUMERIC(5,2),
    defect_count    INTEGER DEFAULT 0,
    tester          VARCHAR(100),
    result          VARCHAR(10),
    tested_at       TIMESTAMP DEFAULT NOW(),
    notes           TEXT
);

INSERT INTO quality_tests (batch_id, stage_code, product_name, test_type, cupping_score, moisture_pct, defect_count, tester, result) VALUES
('B-0841', 'ROASTED',   'Arabica Medium',   'Full Cupping',  86.5, 11.2, 0, 'Sita Rana', 'pass'),
('B-0840', 'GREEN',     'Robusta Dark',     'Standard Cup',  82.1, 11.8, 2, 'Ram KC',    'pass'),
('B-0839', 'PARCHMENT', 'Specialty Light',  'Full Cupping',  89.3, 10.9, 0, 'Sita Rana', 'pass'),
('B-0838', 'ROASTED',   'Espresso Blend',   'Standard Cup',  79.4, 12.6, 8, 'Ram KC',    'fail'),
('B-0837', 'GREEN',     'Arabica Medium',   'Full Cupping',  85.1, 11.4, 1, 'Sita Rana', 'pass')
ON CONFLICT DO NOTHING;

-- ── Orders ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS orders (
    id              SERIAL PRIMARY KEY,
    order_ref       VARCHAR(20) UNIQUE NOT NULL,
    customer_id     INTEGER REFERENCES customers(id),
    product_id      INTEGER REFERENCES products(id),
    qty_kg          NUMERIC(10,3),
    unit_price      NUMERIC(10,2),
    total_amount    NUMERIC(14,2),
    vat_amount      NUMERIC(12,2),
    status          VARCHAR(20) DEFAULT 'pending',
    order_date      TIMESTAMP DEFAULT NOW(),
    delivery_date   TIMESTAMP,
    notes           TEXT
);

INSERT INTO orders (order_ref, customer_id, product_id, qty_kg, unit_price, total_amount, vat_amount, status, order_date, delivery_date) VALUES
('ORD-5210', 1, 1, 50,  840,  42000, 5460, 'delivered',   NOW()-INTERVAL '3 days', NOW()-INTERVAL '1 day'),
('ORD-5211', 2, 2, 30,  720,  21600, 2808, 'processing',  NOW()-INTERVAL '2 days', NOW()+INTERVAL '1 day'),
('ORD-5212', 3, 5, 100, 680,  68000, 8840, 'pending',     NOW()-INTERVAL '1 day',  NOW()+INTERVAL '2 days'),
('ORD-5213', 4, 3, 20,  1600, 32000, 4160, 'delivered',   NOW()-INTERVAL '4 days', NOW()-INTERVAL '2 days'),
('ORD-5214', 5, 4, 60,  900,  54000, 7020, 'pending',     NOW(),                   NOW()+INTERVAL '3 days'),
('ORD-5215', 6, 2, 40,  720,  28800, 3744, 'processing',  NOW()-INTERVAL '1 day',  NOW()+INTERVAL '1 day')
ON CONFLICT (order_ref) DO NOTHING;

-- ── Annual P&L View (from Excel Annual_PnL sheet) ────────────
CREATE OR REPLACE VIEW annual_pnl AS
SELECT
    source,
    ROUND(cup_sales_revenue, 2)           AS cup_sales_revenue_rs,
    ROUND(total_variable_cost_rs, 2)       AS coffee_variable_cost_rs,
    ROUND(contribution_before_fixed, 2)    AS contribution_before_fixed_rs,
    ROUND(annual_fixed_cost, 2)            AS annual_fixed_cost_rs,
    ROUND(net_profit, 2)                   AS net_profit_rs,
    ROUND(net_margin_pct * 100, 2)         AS net_margin_pct,
    ROUND(breakeven_cups_per_day, 2)       AS breakeven_cups_per_day,
    ROUND(cost_per_roasted_kg, 2)          AS cost_per_roasted_kg,
    ROUND(coffee_cost_per_cup, 4)          AS coffee_cost_per_cup
FROM costing_summary
ORDER BY net_profit DESC;

-- ── Summary stats view ────────────────────────────────────────
CREATE OR REPLACE VIEW dashboard_kpis AS
SELECT
    (SELECT COUNT(*) FROM customers WHERE tier IN ('platinum','gold'))    AS premium_customers,
    (SELECT COUNT(*) FROM orders WHERE status = 'pending')               AS pending_orders,
    (SELECT COALESCE(SUM(total_amount),0) FROM orders WHERE order_date >= date_trunc('month', NOW())) AS monthly_revenue,
    (SELECT COUNT(*) FROM production_batches WHERE status = 'in_progress') AS active_batches,
    (SELECT COUNT(*) FROM quality_tests WHERE result = 'fail' AND tested_at >= NOW() - INTERVAL '30 days') AS failed_qc_30d,
    (SELECT source FROM costing_summary ORDER BY net_profit DESC LIMIT 1)  AS most_profitable_source,
    (SELECT source FROM costing_summary ORDER BY cost_per_roasted_kg ASC LIMIT 1) AS lowest_cost_source;

GRANT SELECT ON ALL TABLES IN SCHEMA public TO gulmi;
GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO gulmi;
