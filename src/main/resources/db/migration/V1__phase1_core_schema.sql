CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    display_name text NOT NULL,
    email text,
    auth_subject text,
    status text NOT NULL DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE investor_profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    profile_name text NOT NULL,
    base_currency text NOT NULL DEFAULT 'USD',
    tax_residency_country text,
    investment_objective text,
    risk_notes text,
    is_active boolean NOT NULL DEFAULT true,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE user_preferences (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    default_landing_page text NOT NULL DEFAULT 'home',
    explanation_mode text NOT NULL DEFAULT 'detailed',
    theme_mode text NOT NULL DEFAULT 'system',
    advisor_memory_enabled boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE portfolios (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    investor_profile_id uuid NOT NULL REFERENCES investor_profiles(id),
    name text NOT NULL,
    portfolio_scope text NOT NULL DEFAULT 'country_specific',
    primary_market_country text,
    supported_market_countries jsonb NOT NULL DEFAULT '[]'::jsonb,
    base_currency text NOT NULL DEFAULT 'USD',
    primary_benchmark_symbol text,
    secondary_benchmark_symbol text,
    market_notes text,
    status text NOT NULL DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE brokerage_accounts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id uuid NOT NULL REFERENCES portfolios(id),
    account_name text NOT NULL,
    provider_name text NOT NULL DEFAULT 'manual',
    account_country text,
    account_type text,
    connection_status text NOT NULL DEFAULT 'manual',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE assets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    symbol text NOT NULL,
    asset_type text NOT NULL,
    name text NOT NULL,
    exchange text,
    currency text NOT NULL DEFAULT 'USD',
    country text,
    sector text,
    industry text,
    is_active boolean NOT NULL DEFAULT true,
    provider_metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (symbol, asset_type, exchange)
);

CREATE TABLE holdings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id uuid NOT NULL REFERENCES portfolios(id),
    brokerage_account_id uuid NOT NULL REFERENCES brokerage_accounts(id),
    asset_id uuid NOT NULL REFERENCES assets(id),
    quantity numeric(24, 8) NOT NULL,
    average_cost numeric(20, 6) NOT NULL,
    cost_basis numeric(20, 6),
    portfolio_bucket text NOT NULL DEFAULT 'unclassified',
    source text NOT NULL DEFAULT 'manual',
    notes text,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (portfolio_id, brokerage_account_id, asset_id)
);

CREATE TABLE holding_lots (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    holding_id uuid NOT NULL REFERENCES holdings(id),
    quantity numeric(24, 8) NOT NULL,
    price numeric(20, 6) NOT NULL,
    purchase_date date,
    source text NOT NULL DEFAULT 'manual',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE holding_import_batches (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    portfolio_id uuid NOT NULL REFERENCES portfolios(id),
    source_type text NOT NULL,
    status text NOT NULL,
    file_name text,
    raw_payload jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    completed_at timestamptz
);

CREATE TABLE holding_import_rows (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    batch_id uuid NOT NULL REFERENCES holding_import_batches(id),
    row_number integer NOT NULL,
    symbol text,
    quantity numeric(24, 8),
    average_cost numeric(20, 6),
    purchase_date date,
    validation_status text NOT NULL,
    validation_messages jsonb NOT NULL DEFAULT '[]'::jsonb,
    created_holding_id uuid REFERENCES holdings(id),
    raw_row jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE portfolio_report_preferences (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    portfolio_id uuid NOT NULL REFERENCES portfolios(id),
    report_key text NOT NULL DEFAULT 'overview',
    visualization_key text NOT NULL,
    display_name text NOT NULL,
    chart_type text NOT NULL,
    is_visible boolean NOT NULL DEFAULT true,
    display_order integer NOT NULL,
    config jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (portfolio_id, report_key, visualization_key)
);

CREATE TABLE watchlist_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    asset_id uuid REFERENCES assets(id),
    title text,
    item_type text NOT NULL,
    source_type text,
    source_reference text,
    reason_to_track text,
    status text NOT NULL DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE themes (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    name text NOT NULL,
    description text,
    theme_type text NOT NULL DEFAULT 'custom',
    creation_source text NOT NULL DEFAULT 'manual',
    status text NOT NULL DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE theme_assets (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    theme_id uuid NOT NULL REFERENCES themes(id),
    asset_id uuid NOT NULL REFERENCES assets(id),
    relationship_type text NOT NULL DEFAULT 'core_exposure',
    confidence text NOT NULL DEFAULT 'medium',
    created_at timestamptz NOT NULL DEFAULT now(),
    UNIQUE (theme_id, asset_id)
);

CREATE TABLE external_endpoint_configs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    endpoint_type text NOT NULL,
    provider_name text NOT NULL,
    environment text NOT NULL DEFAULT 'local',
    base_url text,
    api_version text,
    auth_type text NOT NULL DEFAULT 'none',
    secret_reference text,
    timeout_ms integer NOT NULL DEFAULT 5000,
    retry_policy jsonb NOT NULL DEFAULT '{}'::jsonb,
    rate_limit_config jsonb NOT NULL DEFAULT '{}'::jsonb,
    enabled boolean NOT NULL DEFAULT false,
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE provider_configs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    endpoint_config_id uuid REFERENCES external_endpoint_configs(id),
    provider_name text NOT NULL,
    provider_type text NOT NULL,
    active_environment text NOT NULL DEFAULT 'local',
    enabled boolean NOT NULL DEFAULT false,
    config_metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE provider_fetch_runs (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_config_id uuid NOT NULL REFERENCES provider_configs(id),
    run_type text NOT NULL,
    status text NOT NULL,
    started_at timestamptz NOT NULL DEFAULT now(),
    completed_at timestamptz,
    records_received integer NOT NULL DEFAULT 0,
    records_saved integer NOT NULL DEFAULT 0,
    error_summary text
);

CREATE TABLE intelligence_items (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    provider_name text,
    provider_item_id text,
    item_type text NOT NULL,
    headline text NOT NULL,
    summary text,
    source_name text,
    source_url text,
    published_at timestamptz,
    retrieved_at timestamptz,
    source_confidence text NOT NULL DEFAULT 'medium',
    raw_payload jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE intelligence_asset_links (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    intelligence_item_id uuid NOT NULL REFERENCES intelligence_items(id),
    asset_id uuid NOT NULL REFERENCES assets(id),
    relationship_type text NOT NULL DEFAULT 'mentioned',
    confidence text NOT NULL DEFAULT 'medium'
);

CREATE TABLE intelligence_theme_links (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    intelligence_item_id uuid NOT NULL REFERENCES intelligence_items(id),
    theme_id uuid NOT NULL REFERENCES themes(id),
    relationship_type text NOT NULL DEFAULT 'mentioned',
    confidence text NOT NULL DEFAULT 'medium'
);

CREATE TABLE sentiment_signals (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    asset_id uuid REFERENCES assets(id),
    theme_id uuid REFERENCES themes(id),
    intelligence_item_id uuid REFERENCES intelligence_items(id),
    provider_name text,
    signal_type text NOT NULL,
    sentiment_score numeric(9, 6),
    sentiment_label text,
    confidence text NOT NULL DEFAULT 'medium',
    captured_at timestamptz NOT NULL DEFAULT now(),
    raw_payload jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE policy_profiles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    investor_profile_id uuid NOT NULL REFERENCES investor_profiles(id),
    portfolio_id uuid REFERENCES portfolios(id),
    name text NOT NULL,
    scope_type text NOT NULL DEFAULT 'portfolio',
    jurisdiction_scope text,
    market_scope text,
    status text NOT NULL DEFAULT 'active',
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE policy_versions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_profile_id uuid NOT NULL REFERENCES policy_profiles(id),
    version_label text NOT NULL,
    primary_benchmark text,
    secondary_benchmark text,
    cash_target_percentage numeric(9, 6),
    satellite_max_percentage numeric(9, 6),
    drawdown_review_min_percentage numeric(9, 6),
    drawdown_review_max_percentage numeric(9, 6),
    is_active boolean NOT NULL DEFAULT true,
    effective_from timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE policy_rules (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    policy_version_id uuid NOT NULL REFERENCES policy_versions(id),
    rule_key text NOT NULL,
    rule_type text NOT NULL,
    severity text NOT NULL,
    rule_config jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE score_snapshots (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    asset_id uuid REFERENCES assets(id),
    theme_id uuid REFERENCES themes(id),
    watchlist_item_id uuid REFERENCES watchlist_items(id),
    score_version text NOT NULL,
    policy_version_id uuid REFERENCES policy_versions(id),
    overall_label text,
    confidence text NOT NULL DEFAULT 'medium',
    supporting_signals jsonb NOT NULL DEFAULT '[]'::jsonb,
    conflicting_signals jsonb NOT NULL DEFAULT '[]'::jsonb,
    missing_evidence jsonb NOT NULL DEFAULT '[]'::jsonb,
    data_freshness jsonb NOT NULL DEFAULT '[]'::jsonb,
    generated_at timestamptz NOT NULL DEFAULT now(),
    raw_response jsonb NOT NULL DEFAULT '{}'::jsonb
);

CREATE TABLE score_components (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    score_snapshot_id uuid NOT NULL REFERENCES score_snapshots(id),
    component_key text NOT NULL,
    numeric_value numeric(9, 6),
    label text,
    confidence text NOT NULL DEFAULT 'medium',
    supporting_signals jsonb NOT NULL DEFAULT '[]'::jsonb,
    conflicting_signals jsonb NOT NULL DEFAULT '[]'::jsonb,
    missing_evidence jsonb NOT NULL DEFAULT '[]'::jsonb
);

CREATE TABLE insights (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    portfolio_id uuid REFERENCES portfolios(id),
    asset_id uuid REFERENCES assets(id),
    theme_id uuid REFERENCES themes(id),
    watchlist_item_id uuid REFERENCES watchlist_items(id),
    score_snapshot_id uuid REFERENCES score_snapshots(id),
    policy_version_id uuid REFERENCES policy_versions(id),
    label text NOT NULL,
    title text NOT NULL,
    summary text,
    status text NOT NULL DEFAULT 'active',
    generated_at timestamptz NOT NULL DEFAULT now(),
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE insight_evidence_links (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    insight_id uuid NOT NULL REFERENCES insights(id),
    evidence_type text NOT NULL,
    evidence_id uuid NOT NULL,
    relevance_label text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE advisor_chat_sessions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    title text NOT NULL,
    memory_enabled_at_start boolean NOT NULL DEFAULT false,
    created_at timestamptz NOT NULL DEFAULT now(),
    updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE advisor_chat_messages (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    session_id uuid NOT NULL REFERENCES advisor_chat_sessions(id),
    role text NOT NULL,
    content text NOT NULL,
    context_summary text,
    linked_insight_id uuid REFERENCES insights(id),
    linked_score_snapshot_id uuid REFERENCES score_snapshots(id),
    model_provider text,
    model_name text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE audit_events (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES users(id),
    event_type text NOT NULL,
    entity_type text NOT NULL,
    entity_id uuid,
    summary text NOT NULL,
    metadata jsonb NOT NULL DEFAULT '{}'::jsonb,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX idx_portfolios_profile_status ON portfolios(investor_profile_id, status);
CREATE INDEX idx_portfolios_market_status ON portfolios(primary_market_country, status);
CREATE INDEX idx_holdings_portfolio_asset ON holdings(portfolio_id, asset_id);
CREATE INDEX idx_report_preferences_order ON portfolio_report_preferences(user_id, portfolio_id, report_key, display_order);
CREATE INDEX idx_watchlist_user_status ON watchlist_items(user_id, status);
CREATE INDEX idx_themes_user_status ON themes(user_id, status);
CREATE INDEX idx_theme_assets_theme_asset ON theme_assets(theme_id, asset_id);
CREATE INDEX idx_endpoint_provider_env ON external_endpoint_configs(endpoint_type, provider_name, environment);
CREATE INDEX idx_provider_config_provider_type ON provider_configs(provider_name, provider_type, active_environment);
CREATE INDEX idx_intelligence_published_at ON intelligence_items(published_at);
CREATE INDEX idx_intelligence_asset_links_asset ON intelligence_asset_links(asset_id);
CREATE INDEX idx_intelligence_theme_links_theme ON intelligence_theme_links(theme_id);
CREATE INDEX idx_sentiment_asset_captured ON sentiment_signals(asset_id, captured_at);
CREATE INDEX idx_sentiment_theme_captured ON sentiment_signals(theme_id, captured_at);
CREATE INDEX idx_policy_versions_active ON policy_versions(policy_profile_id, is_active);
CREATE INDEX idx_score_snapshots_asset_generated ON score_snapshots(user_id, asset_id, generated_at);
CREATE INDEX idx_insights_user_status_generated ON insights(user_id, status, generated_at);
CREATE INDEX idx_audit_user_created ON audit_events(user_id, created_at);
