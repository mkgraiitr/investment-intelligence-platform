CREATE TABLE holding_valuation_snapshots (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    holding_id uuid NOT NULL REFERENCES holdings(id),
    valuation_date date NOT NULL,
    price numeric(20, 6),
    market_value numeric(20, 6) NOT NULL,
    source text NOT NULL DEFAULT 'manual_seed',
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (holding_id, valuation_date, source)
);

CREATE INDEX idx_holding_valuations_latest ON holding_valuation_snapshots(holding_id, valuation_date DESC, created_at DESC);

UPDATE holdings
SET quantity = 93.33333333,
    average_cost = 175.25,
    cost_basis = 16356.666665
WHERE id = '00000000-0000-0000-0000-000000000601';

UPDATE holdings
SET quantity = 61.66666667,
    average_cost = 410,
    cost_basis = 25283.333335
WHERE id = '00000000-0000-0000-0000-000000000602';

UPDATE holdings
SET quantity = 78.8,
    average_cost = 440,
    cost_basis = 34672
WHERE id = '00000000-0000-0000-0000-000000000603';

UPDATE holdings
SET quantity = 1250,
    average_cost = 5.8,
    cost_basis = 7250
WHERE id = '00000000-0000-0000-0000-000000000604';

UPDATE holdings
SET quantity = 18750,
    average_cost = 1,
    cost_basis = 18750
WHERE id = '00000000-0000-0000-0000-000000000605';

INSERT INTO holding_valuation_snapshots (id, holding_id, valuation_date, price, market_value, source)
VALUES
    ('00000000-0000-0000-0000-000000001901', '00000000-0000-0000-0000-000000000601', '2026-08-09', 225.000000, 21000.000000, 'manual_seed'),
    ('00000000-0000-0000-0000-000000001902', '00000000-0000-0000-0000-000000000602', '2026-08-09', 480.000000, 29600.000000, 'manual_seed'),
    ('00000000-0000-0000-0000-000000001903', '00000000-0000-0000-0000-000000000603', '2026-08-09', 500.000000, 39400.000000, 'manual_seed'),
    ('00000000-0000-0000-0000-000000001904', '00000000-0000-0000-0000-000000000604', '2026-08-09', 13.000000, 16250.000000, 'manual_seed'),
    ('00000000-0000-0000-0000-000000001905', '00000000-0000-0000-0000-000000000605', '2026-08-09', 1.000000, 18750.000000, 'manual_seed')
ON CONFLICT (holding_id, valuation_date, source) DO NOTHING;

UPDATE portfolio_report_preferences
SET display_order = 4
WHERE id = '00000000-0000-0000-0000-000000000703';

INSERT INTO portfolio_report_preferences (
    id,
    user_id,
    portfolio_id,
    report_key,
    visualization_key,
    display_name,
    chart_type,
    is_visible,
    display_order,
    config
)
VALUES (
    '00000000-0000-0000-0000-000000000704',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000301',
    'overview',
    'country_market_exposure',
    'Country / Market Exposure',
    'donut',
    true,
    3,
    '{"show_percentages": true, "show_values": true}'::jsonb
)
ON CONFLICT (portfolio_id, report_key, visualization_key) DO NOTHING;
