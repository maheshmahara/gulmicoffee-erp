{
    'name': 'Gulmi Coffee ERP',
    'version': '17.0.1.0.0',
    'category': 'Manufacturing/Coffee',
    'summary': 'Complete coffee value chain management for Gulmi Coffee Pvt. Ltd.',
    'description': """
Gulmi Coffee ERP Custom Module
================================
Manages the complete coffee value chain:
- Fresh Cherry → Dry Cherry → Parchment → Green Bean → Roasted Bean
- Automated costing per procurement source
- Quality control with SCA cupping score tracking
- Supplier management (Gulmi District farms & co-ops)
- Customer loyalty tiers (Bronze/Silver/Gold/Platinum/Diamond)
- Annual P&L by procurement source
- Nepal VAT (13%) support in NPR
    """,
    'author': 'Gulmi Coffee Pvt. Ltd.',
    'website': 'https://github.com/maheshmahara/gulmicoffee-erp',
    'depends': [
        'base',
        'sale',
        'purchase',
        'stock',
        'mrp',
        'account',
        'quality',
        'contacts',
    ],
    'data': [
        'security/ir.model.access.csv',
        'data/coffee_stages_data.xml',
        'data/costing_inputs_data.xml',
        'views/coffee_costing_views.xml',
        'views/menu_views.xml',
    ],
    'assets': {
        'web.assets_backend': [
            'gulmi_coffee/static/src/css/gulmi.css',
        ],
    },
    'images': ['static/description/icon.png'],
    'installable': True,
    'auto_install': False,
    'application': True,
    'license': 'LGPL-3',
}
