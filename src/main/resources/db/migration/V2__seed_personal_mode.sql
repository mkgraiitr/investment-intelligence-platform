INSERT INTO users (id, display_name, email, status)
VALUES ('00000000-0000-0000-0000-000000000001', 'Personal User', 'personal.local@example.invalid', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO investor_profiles (
    id,
    user_id,
    profile_name,
    base_currency,
    tax_residency_country,
    investment_objective,
    risk_notes,
    is_active
)
VALUES (
    '00000000-0000-0000-0000-000000000101',
    '00000000-0000-0000-0000-000000000001',
    'Personal Profile',
    'USD',
    'SG',
    'Personal portfolio intelligence and market research.',
    'Technology-oriented portfolio with configurable cash and satellite exposure.',
    true
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO user_preferences (
    id,
    user_id,
    default_landing_page,
    explanation_mode,
    theme_mode,
    advisor_memory_enabled
)
VALUES (
    '00000000-0000-0000-0000-000000000201',
    '00000000-0000-0000-0000-000000000001',
    'home',
    'detailed',
    'system',
    false
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO portfolios (
    id,
    user_id,
    investor_profile_id,
    name,
    portfolio_scope,
    primary_market_country,
    supported_market_countries,
    base_currency,
    primary_benchmark_symbol,
    secondary_benchmark_symbol,
    market_notes,
    status
)
VALUES (
    '00000000-0000-0000-0000-000000000301',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000101',
    'US Portfolio',
    'country_specific',
    'US',
    '["US"]'::jsonb,
    'USD',
    'NASDAQ_100_TR',
    'SP500_TR',
    'US-listed stocks and ETFs with a technology tilt.',
    'active'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO brokerage_accounts (
    id,
    portfolio_id,
    account_name,
    provider_name,
    account_country,
    account_type,
    connection_status
)
VALUES (
    '00000000-0000-0000-0000-000000000401',
    '00000000-0000-0000-0000-000000000301',
    'Manual US Account',
    'manual',
    'US',
    'taxable',
    'manual'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO assets (id, symbol, asset_type, name, exchange, currency, country, sector, industry)
VALUES
    ('00000000-0000-0000-0000-000000000501', 'AAPL', 'stock', 'Apple Inc.', 'NASDAQ', 'USD', 'US', 'Technology', 'Consumer Electronics'),
    ('00000000-0000-0000-0000-000000000502', 'MSFT', 'stock', 'Microsoft Corporation', 'NASDAQ', 'USD', 'US', 'Technology', 'Software'),
    ('00000000-0000-0000-0000-000000000503', 'QQQ', 'etf', 'Invesco QQQ Trust', 'NASDAQ', 'USD', 'US', 'ETF', 'Large Cap Growth'),
    ('00000000-0000-0000-0000-000000000504', 'RKLB', 'stock', 'Rocket Lab USA Inc.', 'NASDAQ', 'USD', 'US', 'Industrials', 'Aerospace & Defense'),
    ('00000000-0000-0000-0000-000000000505', 'CASH', 'cash', 'Cash Reserve', NULL, 'USD', 'US', 'Cash', 'Cash')
ON CONFLICT (id) DO NOTHING;

INSERT INTO holdings (
    id,
    portfolio_id,
    brokerage_account_id,
    asset_id,
    quantity,
    average_cost,
    cost_basis,
    portfolio_bucket,
    source,
    notes
)
VALUES
    ('00000000-0000-0000-0000-000000000601', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000501', 10.5, 175.25, 1840.125, 'core', 'json_upload', 'Sample seeded holding.'),
    ('00000000-0000-0000-0000-000000000602', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000502', 8, 410, 3280, 'core', 'manual', 'Sample seeded holding.'),
    ('00000000-0000-0000-0000-000000000603', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000503', 35, 440, 15400, 'core', 'manual', 'Sample ETF holding.'),
    ('00000000-0000-0000-0000-000000000604', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000504', 300, 5.8, 1740, 'satellite', 'manual', 'High-risk tracking sample.'),
    ('00000000-0000-0000-0000-000000000605', '00000000-0000-0000-0000-000000000301', '00000000-0000-0000-0000-000000000401', '00000000-0000-0000-0000-000000000505', 18750, 1, 18750, 'cash', 'manual', 'Flexible cash target sample.')
ON CONFLICT (id) DO NOTHING;

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
VALUES
    ('00000000-0000-0000-0000-000000000701', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000301', 'overview', 'core_satellite_cash', 'Core / Satellite / Cash', 'donut', true, 1, '{"show_percentages": true, "show_values": true}'::jsonb),
    ('00000000-0000-0000-0000-000000000702', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000301', 'overview', 'sector_allocation', 'Sector Allocation', 'donut', true, 2, '{"show_percentages": true, "group_small_slices": true}'::jsonb),
    ('00000000-0000-0000-0000-000000000703', '00000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000301', 'overview', 'holding_concentration', 'Holding Concentration', 'bar', true, 3, '{"top_n": 10, "show_threshold_lines": true}'::jsonb)
ON CONFLICT (id) DO NOTHING;

INSERT INTO themes (id, user_id, name, description, theme_type, creation_source, status)
VALUES
    ('00000000-0000-0000-0000-000000000801', '00000000-0000-0000-0000-000000000001', 'Space Economy', 'Companies exposed to space launch, satellites, defense, and space infrastructure.', 'technology', 'manual', 'active'),
    ('00000000-0000-0000-0000-000000000802', '00000000-0000-0000-0000-000000000001', 'AI Infrastructure', 'Semiconductors, cloud, networking, and infrastructure powering AI workloads.', 'technology', 'manual', 'active')
ON CONFLICT (id) DO NOTHING;

INSERT INTO theme_assets (id, theme_id, asset_id, relationship_type, confidence)
VALUES
    ('00000000-0000-0000-0000-000000000901', '00000000-0000-0000-0000-000000000801', '00000000-0000-0000-0000-000000000504', 'core_exposure', 'medium'),
    ('00000000-0000-0000-0000-000000000902', '00000000-0000-0000-0000-000000000802', '00000000-0000-0000-0000-000000000502', 'core_exposure', 'medium')
ON CONFLICT (id) DO NOTHING;

INSERT INTO watchlist_items (
    id,
    user_id,
    asset_id,
    item_type,
    source_type,
    source_reference,
    reason_to_track,
    status
)
VALUES (
    '00000000-0000-0000-0000-000000001001',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000504',
    'stock',
    'manual',
    'Seeded sample',
    'Space economy exposure; high-risk tracking only.',
    'active'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO policy_profiles (
    id,
    user_id,
    investor_profile_id,
    portfolio_id,
    name,
    scope_type,
    jurisdiction_scope,
    market_scope,
    status
)
VALUES (
    '00000000-0000-0000-0000-000000001101',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000101',
    '00000000-0000-0000-0000-000000000301',
    'Personal Investment Policy',
    'portfolio',
    'SG tax resident',
    'US-listed assets',
    'active'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO policy_versions (
    id,
    policy_profile_id,
    version_label,
    primary_benchmark,
    secondary_benchmark,
    cash_target_percentage,
    satellite_max_percentage,
    drawdown_review_min_percentage,
    drawdown_review_max_percentage,
    is_active
)
VALUES (
    '00000000-0000-0000-0000-000000001201',
    '00000000-0000-0000-0000-000000001101',
    'policy-v0.3',
    'NASDAQ_100_TR',
    'SP500_TR',
    0.15,
    0.20,
    0.15,
    0.25,
    true
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO policy_rules (id, policy_version_id, rule_key, rule_type, severity, rule_config)
VALUES
    ('00000000-0000-0000-0000-000000001301', '00000000-0000-0000-0000-000000001201', 'cash_target', 'cash', 'info', '{"target": 0.15, "hard_minimum": false}'::jsonb),
    ('00000000-0000-0000-0000-000000001302', '00000000-0000-0000-0000-000000001201', 'satellite_max', 'concentration', 'warning', '{"max": 0.20}'::jsonb),
    ('00000000-0000-0000-0000-000000001303', '00000000-0000-0000-0000-000000001201', 'forbidden_positive_labels', 'labeling', 'blocker', '{"forbidden": ["Buy", "Sell", "Strong Buy", "Strong Sell", "Target Price"]}'::jsonb)
ON CONFLICT (id) DO NOTHING;

INSERT INTO external_endpoint_configs (
    id,
    name,
    endpoint_type,
    provider_name,
    environment,
    base_url,
    api_version,
    auth_type,
    secret_reference,
    enabled
)
VALUES
    ('00000000-0000-0000-0000-000000001401', 'Alpha Vantage API', 'provider_api', 'alpha_vantage', 'production', 'https://www.alphavantage.co/query', NULL, 'api_key', 'ALPHA_VANTAGE_API_KEY', false),
    ('00000000-0000-0000-0000-000000001402', 'Finnhub News API', 'provider_api', 'finnhub', 'production', 'https://finnhub.io/api/v1', 'v1', 'api_key', 'FINNHUB_API_KEY', false),
    ('00000000-0000-0000-0000-000000001403', 'AI Provider Placeholder', 'ai_model', 'disabled', 'local', NULL, NULL, 'none', NULL, false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO provider_configs (id, endpoint_config_id, provider_name, provider_type, active_environment, enabled)
VALUES
    ('00000000-0000-0000-0000-000000001501', '00000000-0000-0000-0000-000000001401', 'alpha_vantage', 'market_data', 'production', false),
    ('00000000-0000-0000-0000-000000001502', '00000000-0000-0000-0000-000000001402', 'finnhub', 'news', 'production', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO score_snapshots (
    id,
    user_id,
    asset_id,
    score_version,
    policy_version_id,
    overall_label,
    confidence,
    supporting_signals,
    conflicting_signals,
    missing_evidence,
    data_freshness,
    raw_response
)
VALUES (
    '00000000-0000-0000-0000-000000001601',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000502',
    'score-framework-v0.1',
    '00000000-0000-0000-0000-000000001201',
    'Research Further',
    'medium',
    '["Strong quality placeholder"]'::jsonb,
    '["Valuation requires review"]'::jsonb,
    '["Live provider data disabled in Phase 1"]'::jsonb,
    '["Seeded sample data"]'::jsonb,
    '{"phase": "traditional-core", "ai_enabled": false}'::jsonb
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO insights (
    id,
    user_id,
    portfolio_id,
    asset_id,
    score_snapshot_id,
    policy_version_id,
    label,
    title,
    summary,
    status
)
VALUES (
    '00000000-0000-0000-0000-000000001701',
    '00000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000301',
    '00000000-0000-0000-0000-000000000502',
    '00000000-0000-0000-0000-000000001601',
    '00000000-0000-0000-0000-000000001201',
    'Research Further',
    'MSFT deserves deeper review',
    'Seeded Phase 1 insight. Generated from scoring and policy context, not AI.',
    'active'
)
ON CONFLICT (id) DO NOTHING;

INSERT INTO audit_events (id, user_id, event_type, entity_type, entity_id, summary, metadata)
VALUES (
    '00000000-0000-0000-0000-000000001801',
    '00000000-0000-0000-0000-000000000001',
    'personal_mode_seeded',
    'portfolio',
    '00000000-0000-0000-0000-000000000301',
    'Seeded personal-mode Phase 1 data.',
    '{"ai_enabled": false, "phase": "traditional-core"}'::jsonb
)
ON CONFLICT (id) DO NOTHING;
