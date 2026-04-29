from odoo import models, fields, api

class CoffeeStage(models.Model):
    _name = 'gulmi.coffee.stage'
    _description = 'Coffee Processing Stage'
    _order = 'sequence'

    code        = fields.Char(required=True)
    name        = fields.Char(required=True)
    sequence    = fields.Integer(default=10)
    description = fields.Text()

    _sql_constraints = [
        ('code_unique', 'UNIQUE(code)', 'Stage code must be unique.')
    ]


class CoffeeCosting(models.Model):
    _name = 'gulmi.coffee.costing'
    _description = 'Coffee Costing by Procurement Source'
    _rec_name = 'source'

    source                    = fields.Selection([
        ('Fresh Cherry', 'Fresh Cherry'),
        ('Dry Cherry',   'Dry Cherry'),
        ('Parchment',    'Parchment'),
        ('Green Beans',  'Green Beans'),
    ], required=True, string='Procurement Source')

    # ── Inputs ──────────────────────────────────
    input_qty_kg              = fields.Float('Input Qty (kg)', digits=(12, 3))
    purchase_price            = fields.Float('Purchase Price (Rs/kg)', digits=(10, 2))

    # ── Yields ──────────────────────────────────
    stage_yield               = fields.Float('Stage Yield %', digits=(5, 4))
    green_to_roasted_yield    = fields.Float('Green→Roasted Yield %', digits=(5, 4), default=0.85)
    cups_per_kg               = fields.Float('Cups per kg Roasted', default=50)

    # ── Costs ───────────────────────────────────
    procurement_cost          = fields.Float('Procurement Cost (Rs)', compute='_compute_costs', store=True)
    transport_cost            = fields.Float('Transport Cost (Rs)', compute='_compute_costs', store=True)
    processing_cost           = fields.Float('Processing Cost (Rs)', compute='_compute_costs', store=True)
    hulling_cost              = fields.Float('Hulling Cost (Rs)', compute='_compute_costs', store=True)
    roasting_cost             = fields.Float('Roasting Cost (Rs)', compute='_compute_costs', store=True)
    packaging_cost            = fields.Float('Packaging Cost (Rs)', compute='_compute_costs', store=True)
    total_variable_cost       = fields.Float('Total Variable Cost (Rs)', compute='_compute_costs', store=True)

    # ── Output ──────────────────────────────────
    roasted_output_kg         = fields.Float('Roasted Output (kg)', compute='_compute_costs', store=True)
    cups_produced             = fields.Float('Cups Produced', compute='_compute_costs', store=True)
    cost_per_roasted_kg       = fields.Float('Cost/Roasted kg (Rs)', compute='_compute_costs', store=True)
    coffee_cost_per_cup       = fields.Float('Coffee Cost/Cup (Rs)', compute='_compute_costs', store=True)

    # ── P&L ─────────────────────────────────────
    cup_selling_price         = fields.Float('Cup Selling Price (Rs)', default=130)
    cafe_variable_per_cup     = fields.Float('Café Variable/Cup (Rs)', default=30)
    cup_sales_revenue         = fields.Float('Cup Sales Revenue (Rs)', compute='_compute_pnl', store=True)
    contribution_before_fixed = fields.Float('Contribution (Rs)', compute='_compute_pnl', store=True)
    annual_fixed_cost         = fields.Float('Annual Fixed Cost (Rs)', default=416000)
    net_profit                = fields.Float('Net Profit (Rs)', compute='_compute_pnl', store=True)
    net_margin_pct            = fields.Float('Net Margin %', compute='_compute_pnl', store=True)
    breakeven_cups_per_day    = fields.Float('Breakeven Cups/Day', compute='_compute_pnl', store=True)

    # ── Rate inputs ─────────────────────────────
    transport_rate            = fields.Float('Transport Rate (Rs/kg)', default=30)
    processing_rate           = fields.Float('Processing Rate (Rs/kg)', default=20)
    hulling_electricity_rate  = fields.Float('Hulling Electricity (Rs/kg)', default=25)
    hulling_labour_rate       = fields.Float('Hulling Labour (Rs/kg)', default=10)
    roasting_electricity_rate = fields.Float('Roasting Electricity (Rs/kg)', default=25)
    roasting_labour_rate      = fields.Float('Roasting Labour (Rs/kg)', default=10)
    packaging_rate            = fields.Float('Packaging Rate (Rs/kg roasted)', default=60)

    @api.depends('source', 'input_qty_kg', 'purchase_price', 'stage_yield',
                 'green_to_roasted_yield', 'cups_per_kg',
                 'transport_rate', 'processing_rate',
                 'hulling_electricity_rate', 'hulling_labour_rate',
                 'roasting_electricity_rate', 'roasting_labour_rate',
                 'packaging_rate')
    def _compute_costs(self):
        for r in self:
            qty   = r.input_qty_kg or 0
            price = r.purchase_price or 0
            src   = r.source

            r.procurement_cost = qty * price
            r.transport_cost   = qty * r.transport_rate

            if src == 'Fresh Cherry':
                r.processing_cost  = qty * r.processing_rate
                parchment_kg       = qty * (r.stage_yield or 0.5)
                green_kg           = parchment_kg * 0.75
                r.hulling_cost     = parchment_kg * (r.hulling_electricity_rate + r.hulling_labour_rate)
            elif src == 'Dry Cherry':
                r.processing_cost  = qty * 10
                green_kg           = qty * (r.stage_yield or 0.8)
                r.hulling_cost     = 0
            elif src == 'Parchment':
                r.processing_cost  = 0
                green_kg           = qty * (r.stage_yield or 0.75)
                r.hulling_cost     = qty * (r.hulling_electricity_rate + r.hulling_labour_rate)
            else:  # Green Beans
                r.processing_cost  = 0
                green_kg           = qty
                r.hulling_cost     = 0

            roasted_kg             = green_kg * (r.green_to_roasted_yield or 0.85)
            r.roasted_output_kg    = roasted_kg
            r.roasting_cost        = green_kg * (r.roasting_electricity_rate + r.roasting_labour_rate)
            r.packaging_cost       = roasted_kg * r.packaging_rate
            r.total_variable_cost  = (r.procurement_cost + r.transport_cost +
                                      r.processing_cost + r.hulling_cost +
                                      r.roasting_cost + r.packaging_cost)
            r.cups_produced        = roasted_kg * (r.cups_per_kg or 50)
            r.cost_per_roasted_kg  = r.total_variable_cost / roasted_kg if roasted_kg else 0
            r.coffee_cost_per_cup  = r.total_variable_cost / r.cups_produced if r.cups_produced else 0

    @api.depends('cups_produced', 'cup_selling_price', 'cafe_variable_per_cup',
                 'total_variable_cost', 'annual_fixed_cost')
    def _compute_pnl(self):
        for r in self:
            cups = r.cups_produced or 0
            r.cup_sales_revenue         = cups * r.cup_selling_price
            cafe_var                    = cups * r.cafe_variable_per_cup
            r.contribution_before_fixed = r.cup_sales_revenue - r.total_variable_cost - cafe_var
            r.net_profit                = r.contribution_before_fixed - r.annual_fixed_cost
            r.net_margin_pct            = (r.net_profit / r.cup_sales_revenue * 100
                                           if r.cup_sales_revenue else 0)
            contrib_per_cup = (r.cup_selling_price - r.coffee_cost_per_cup - r.cafe_variable_per_cup)
            r.breakeven_cups_per_day    = (r.annual_fixed_cost / 365 / contrib_per_cup
                                           if contrib_per_cup > 0 else 0)


class GulmiSupplier(models.Model):
    _inherit = 'res.partner'

    is_coffee_supplier  = fields.Boolean('Coffee Supplier')
    region              = fields.Char('Region / District')
    bean_type           = fields.Selection([
        ('arabica',   'Arabica'),
        ('robusta',   'Robusta'),
        ('specialty', 'Specialty'),
        ('mixed',     'Mixed'),
    ], string='Bean Type')
    supply_stage        = fields.Many2one('gulmi.coffee.stage', string='Supplies Stage')
    supplier_rating     = fields.Selection([
        ('5', '★★★★★'), ('4', '★★★★☆'),
        ('3', '★★★☆☆'), ('2', '★★☆☆☆'), ('1', '★☆☆☆☆'),
    ], string='Rating')


class GulmiCustomer(models.Model):
    _inherit = 'res.partner'

    is_cafe_customer    = fields.Boolean('Café/B2B Customer')
    loyalty_tier        = fields.Selection([
        ('bronze',   'Bronze'),
        ('silver',   'Silver'),
        ('gold',     'Gold'),
        ('platinum', 'Platinum'),
        ('diamond',  'Diamond'),
    ], string='Loyalty Tier', default='bronze')
    loyalty_points      = fields.Integer('Loyalty Points', default=0)
    annual_spend        = fields.Float('Annual Spend (Rs)', digits=(14, 2))
    business_type       = fields.Selection([
        ('horeca',   'HoReCa'),
        ('hotel',    'Hotel'),
        ('cafe',     'Café'),
        ('roaster',  'Roaster'),
        ('retailer', 'Retailer'),
        ('resort',   'Resort'),
    ], string='Business Type')
