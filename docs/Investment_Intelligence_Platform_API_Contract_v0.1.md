# Investment Intelligence Platform

## API Contract v0.1

Prepared: 2026-08-08

Status: Initial API contract baseline

## 1. Purpose

This document defines the first API contract for the Investment Intelligence Platform.

The product will use HTMX and server-rendered pages for the main user interface, while still exposing structured JSON contracts for engines, provider adapters, imports, and future integrations.

This contract is intentionally v0.1. It is meant to guide the first Spring Boot implementation without locking the project into final scoring formulas, broker integrations, AI model providers, or public advisory behavior.

## 2. API Design Principles

- Keep UI routes and JSON API routes separate.
- Use HTMX endpoints for page fragments and interactive screens.
- Use JSON endpoints for engines, adapters, imports, and future integrations.
- Do not expose buy/sell or trade execution endpoints in v1.
- Keep Insights evidence-bound and non-execution oriented.
- Keep provider endpoints configurable.
- Keep scoring and policy versioned.
- Return source freshness, confidence, and missing-evidence metadata where relevant.
- Keep user ownership explicit even in personal-use mode.

## 3. Route Groups

| Route group | Purpose | Response type |
|---|---|---|
| `/` and `/app/**` | Server-rendered application pages | HTML |
| `/hx/**` | HTMX partials and form actions | HTML fragments |
| `/api/v1/**` | JSON API for domain data, engines, adapters, and future integrations | JSON |
| `/actuator/**` | Spring Boot health/ops endpoints | JSON |

Recommended rule:

- Browser navigation should use `/app/**`.
- HTMX partial refreshes should use `/hx/**`.
- Internal engine contracts and integration-friendly responses should use `/api/v1/**`.

## 4. Shared API Conventions

### IDs

Use UUID strings for persistent entity IDs.

```json
{
  "portfolio_id": "d6e0f92f-9d80-4e4a-a49f-736aa1f13c2c"
}
```

### Dates and timestamps

- Use ISO-8601 dates for date-only fields.
- Use ISO-8601 UTC timestamps for event timestamps.

```json
{
  "purchase_date": "2026-03-15",
  "generated_at": "2026-08-08T00:00:00Z"
}
```

### Money and quantities

Use JSON numbers for API payloads where precision is acceptable for transport, but persist as PostgreSQL `numeric`.

```json
{
  "shares": 10.5,
  "avg_buy_price": 175.25
}
```

### Standard success envelope

Simple read endpoints may return direct resource payloads. Mutation endpoints should return an envelope.

```json
{
  "success": true,
  "message": "Holding created.",
  "data": {}
}
```

### Standard error envelope

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more fields are invalid.",
    "details": [
      {
        "field": "ticker",
        "message": "Ticker is required."
      }
    ]
  }
}
```

### Common HTTP statuses

| Status | Meaning |
|---|---|
| `200` | Successful read/update |
| `201` | Created |
| `202` | Accepted for async processing |
| `204` | Successful action with no response body |
| `400` | Invalid request |
| `401` | Authentication required later |
| `403` | Not allowed |
| `404` | Resource not found |
| `409` | Conflict or duplicate |
| `422` | Semantic validation failed |
| `500` | Unexpected system error |

## 5. Page Routes

These routes return full HTML pages.

| Method | Route | Page |
|---|---|---|
| `GET` | `/` | Redirects to `/app/home` |
| `GET` | `/app/home` | Home / Daily Brief |
| `GET` | `/app/portfolio` | Portfolio |
| `GET` | `/app/discover` | Discover |
| `GET` | `/app/watchlist` | Watchlist & Themes |
| `GET` | `/app/research` | Research / Analysis Workspace |
| `GET` | `/app/insights` | Insights |
| `GET` | `/app/intelligence` | Intelligence |
| `GET` | `/app/policy-settings` | Policy & Settings |

The global Advisor Chat panel can be included in the base layout and updated through HTMX partial routes.

## 6. HTMX Fragment Routes

These routes return HTML fragments. They are designed for dynamic screens without building a large SPA.

### Home / Daily Brief

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/home/daily-brief` | Refresh daily brief cards |
| `GET` | `/hx/home/attention-items` | Refresh alerts and items needing attention |

### Portfolio

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/portfolio/context` | Refresh selected portfolio context bar |
| `GET` | `/hx/portfolio/summary` | Refresh allocation, cash, benchmark, and concentration summary |
| `GET` | `/hx/portfolio/report-visualizations` | Refresh configurable portfolio report charts |
| `GET` | `/hx/portfolio/report-visualizations/settings` | Render chart selection and ordering settings |
| `POST` | `/hx/portfolio/report-visualizations/preferences` | Save chart visibility, order, and chart type preferences |
| `GET` | `/hx/portfolio/holdings` | Refresh holdings table |
| `GET` | `/hx/portfolio/holdings/new` | Render add-holding form |
| `POST` | `/hx/portfolio/holdings` | Create holding and return updated holdings fragment |
| `GET` | `/hx/portfolio/holdings/{holdingId}/edit` | Render edit-holding form |
| `POST` | `/hx/portfolio/holdings/{holdingId}` | Update holding and return updated holdings fragment |
| `POST` | `/hx/portfolio/holdings/{holdingId}/archive` | Archive holding and return updated holdings fragment |
| `POST` | `/hx/portfolio/imports/preview` | Preview JSON holdings import |
| `POST` | `/hx/portfolio/imports/{batchId}/commit` | Commit validated holdings import |

### Discover

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/discover/market-scanner` | Refresh market scanner results |
| `GET` | `/hx/discover/hot-themes` | Refresh hot themes |
| `GET` | `/hx/discover/sentiment-movers` | Refresh sentiment movers |
| `GET` | `/hx/discover/speculative-radar` | Refresh high-risk tracking candidates |
| `POST` | `/hx/discover/items/{assetId}/watchlist` | Add discovered asset to watchlist |

### Watchlist & Themes

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/watchlist/items` | Refresh watchlist table/cards |
| `GET` | `/hx/watchlist/items/new` | Render add-watchlist-item form |
| `POST` | `/hx/watchlist/items` | Create watchlist item |
| `POST` | `/hx/watchlist/items/{watchlistItemId}/archive` | Archive watchlist item |
| `GET` | `/hx/themes` | Refresh themes list |
| `GET` | `/hx/themes/new` | Render create-theme form |
| `POST` | `/hx/themes` | Create theme |
| `POST` | `/hx/themes/{themeId}/assets` | Link asset to theme |

### Research / Analysis Workspace

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/research/asset-search` | Search/select asset |
| `GET` | `/hx/research/assets/{assetId}/overview` | Refresh asset overview |
| `GET` | `/hx/research/assets/{assetId}/scores` | Refresh score panel |
| `GET` | `/hx/research/assets/{assetId}/intelligence` | Refresh intelligence panel |
| `GET` | `/hx/research/assets/{assetId}/explainability` | Refresh explainability panel |

### Insights

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/insights/list` | Refresh insights list |
| `GET` | `/hx/insights/{insightId}` | Render insight detail |
| `POST` | `/hx/insights/{insightId}/dismiss` | Dismiss insight |
| `POST` | `/hx/insights/{insightId}/archive` | Archive insight |

### Intelligence

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/intelligence/items` | Refresh intelligence feed |
| `GET` | `/hx/intelligence/sentiment` | Refresh sentiment summary |
| `GET` | `/hx/intelligence/provider-runs` | Refresh provider fetch run history |

### Policy & Settings

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/settings/profile` | Render profile settings |
| `POST` | `/hx/settings/profile` | Update profile settings |
| `GET` | `/hx/settings/policy` | Render policy settings |
| `POST` | `/hx/settings/policy` | Create new policy version |
| `GET` | `/hx/settings/provider-endpoints` | Render endpoint configuration list |
| `POST` | `/hx/settings/provider-endpoints` | Create/update external endpoint configuration |
| `POST` | `/hx/settings/advisor-memory` | Toggle Advisor Chat memory |

### Advisor Chat

| Method | Route | Purpose |
|---|---|---|
| `GET` | `/hx/advisor-chat/panel` | Render global Advisor Chat panel |
| `POST` | `/hx/advisor-chat/messages` | Send message and return updated chat fragment |
| `POST` | `/hx/advisor-chat/sessions/{sessionId}/archive` | Archive chat session |

## 7. JSON API: User, Profile and Preferences

The first implementation should not expose public registration or login APIs. It should run in personal/local mode with one seeded user and use `/api/v1/me` to return that user context.

Future public registration and authentication APIs are deferred.

### Get current user context

`GET /api/v1/me`

Response:

```json
{
  "user": {
    "id": "user-uuid",
    "display_name": "Personal User",
    "status": "active"
  },
  "active_investor_profile": {
    "id": "profile-uuid",
    "profile_name": "Personal Profile",
    "base_currency": "USD",
    "tax_residency_country": "SG"
  },
  "preferences": {
    "default_landing_page": "home",
    "explanation_mode": "detailed",
    "theme_mode": "system",
    "advisor_memory_enabled": true
  }
}
```

### Update preferences

`PATCH /api/v1/me/preferences`

Request:

```json
{
  "default_landing_page": "home",
  "explanation_mode": "detailed",
  "theme_mode": "dark",
  "advisor_memory_enabled": false
}
```

Response: standard success envelope.

## 8. JSON API: Portfolio

### List portfolios

`GET /api/v1/portfolios`

Response:

```json
{
  "portfolios": [
    {
      "id": "portfolio-uuid",
      "name": "US Portfolio",
      "portfolio_scope": "country_specific",
      "primary_market_country": "US",
      "supported_market_countries": ["US"],
      "base_currency": "USD",
      "primary_benchmark_symbol": "NASDAQ_100_TR",
      "secondary_benchmark_symbol": "SP500_TR",
      "status": "active"
    }
  ]
}
```

### Create portfolio

`POST /api/v1/portfolios`

Request:

```json
{
  "investor_profile_id": "profile-uuid",
  "name": "US Portfolio",
  "portfolio_scope": "country_specific",
  "primary_market_country": "US",
  "supported_market_countries": ["US"],
  "base_currency": "USD",
  "primary_benchmark_symbol": "NASDAQ_100_TR",
  "secondary_benchmark_symbol": "SP500_TR",
  "market_notes": "US-listed stocks and ETFs with technology tilt."
}
```

Response: created portfolio resource.

### Get portfolio summary

`GET /api/v1/portfolios/{portfolioId}/summary`

Response:

```json
{
  "portfolio": {
    "id": "portfolio-uuid",
    "name": "US Portfolio",
    "primary_market_country": "US",
    "base_currency": "USD"
  },
  "valuation": {
    "total_market_value": 125000.00,
    "cash_value": 18750.00,
    "cash_percentage": 0.15
  },
  "allocation": {
    "core_percentage": 0.72,
    "satellite_percentage": 0.18,
    "cash_percentage": 0.10
  },
  "benchmarks": {
    "primary": {
      "symbol": "NASDAQ_100_TR",
      "name": "Nasdaq-100 Total Return",
      "ytd_return": 0.114
    },
    "secondary": {
      "symbol": "SP500_TR",
      "name": "S&P 500 Total Return",
      "ytd_return": 0.082
    }
  },
  "policy_warnings": []
}
```

### Get portfolio report visualization preferences

`GET /api/v1/portfolios/{portfolioId}/report-preferences?report_key=overview`

Response:

```json
{
  "portfolio_id": "portfolio-uuid",
  "report_key": "overview",
  "visualizations": [
    {
      "visualization_key": "core_satellite_cash",
      "display_name": "Core / Satellite / Cash",
      "chart_type": "donut",
      "is_visible": true,
      "display_order": 1,
      "allowed_chart_types": ["donut", "pie", "bar", "table"],
      "config": {
        "show_percentages": true,
        "show_values": true
      }
    },
    {
      "visualization_key": "sector_allocation",
      "display_name": "Sector Allocation",
      "chart_type": "donut",
      "is_visible": true,
      "display_order": 2,
      "allowed_chart_types": ["donut", "pie", "bar", "treemap", "table"],
      "config": {
        "show_percentages": true,
        "group_small_slices": true
      }
    }
  ]
}
```

### Update portfolio report visualization preferences

`PUT /api/v1/portfolios/{portfolioId}/report-preferences`

Request:

```json
{
  "report_key": "overview",
  "visualizations": [
    {
      "visualization_key": "core_satellite_cash",
      "chart_type": "donut",
      "is_visible": true,
      "display_order": 1,
      "config": {
        "show_percentages": true,
        "show_values": true
      }
    },
    {
      "visualization_key": "holding_concentration",
      "chart_type": "bar",
      "is_visible": true,
      "display_order": 2,
      "config": {
        "top_n": 10,
        "show_threshold_lines": true
      }
    }
  ]
}
```

Response: standard success envelope.

### Get portfolio report chart data

`GET /api/v1/portfolios/{portfolioId}/report-visualizations?report_key=overview`

Response:

```json
{
  "portfolio_id": "portfolio-uuid",
  "report_key": "overview",
  "generated_at": "2026-08-09T00:00:00Z",
  "charts": [
    {
      "visualization_key": "core_satellite_cash",
      "display_name": "Core / Satellite / Cash",
      "chart_type": "donut",
      "data": [
        {
          "label": "Core",
          "value": 90000.00,
          "percentage": 0.72
        },
        {
          "label": "Satellite",
          "value": 22500.00,
          "percentage": 0.18
        },
        {
          "label": "Cash",
          "value": 12500.00,
          "percentage": 0.10
        }
      ]
    }
  ]
}
```

## 9. JSON API: Holdings and Imports

### List holdings

`GET /api/v1/portfolios/{portfolioId}/holdings`

Response:

```json
{
  "holdings": [
    {
      "id": "holding-uuid",
      "asset": {
        "id": "asset-uuid",
        "symbol": "AAPL",
        "name": "Apple Inc.",
        "asset_type": "stock",
        "exchange": "NASDAQ",
        "country": "US",
        "currency": "USD"
      },
      "quantity": 10.5,
      "average_cost": 175.25,
      "portfolio_bucket": "core",
      "source": "json_upload"
    }
  ]
}
```

### Create holding

`POST /api/v1/portfolios/{portfolioId}/holdings`

Request:

```json
{
  "brokerage_account_id": "account-uuid",
  "ticker": "AAPL",
  "shares": 10.5,
  "avg_buy_price": 175.25,
  "purchase_date": "2026-03-15",
  "portfolio_bucket": "core",
  "notes": "Initial manual import"
}
```

Response: created holding resource.

### Preview holdings JSON import

`POST /api/v1/portfolios/{portfolioId}/holding-imports/preview`

Request:

```json
[
  {
    "ticker": "AAPL",
    "shares": 10.5,
    "avg_buy_price": 175.25,
    "purchase_date": "2026-03-15"
  }
]
```

Response:

```json
{
  "batch_id": "batch-uuid",
  "status": "previewed",
  "rows": [
    {
      "row_number": 1,
      "ticker": "AAPL",
      "validation_status": "valid",
      "validation_messages": []
    }
  ],
  "summary": {
    "total_rows": 1,
    "valid_rows": 1,
    "warning_rows": 0,
    "invalid_rows": 0
  }
}
```

### Commit holdings import

`POST /api/v1/portfolios/{portfolioId}/holding-imports/{batchId}/commit`

Response:

```json
{
  "success": true,
  "message": "Holdings import completed.",
  "data": {
    "batch_id": "batch-uuid",
    "created_holdings": 1,
    "updated_holdings": 0,
    "skipped_rows": 0
  }
}
```

## 10. JSON API: Assets

### Search assets

`GET /api/v1/assets/search?q=AAPL&asset_type=stock&country=US`

Response:

```json
{
  "assets": [
    {
      "id": "asset-uuid",
      "symbol": "AAPL",
      "name": "Apple Inc.",
      "asset_type": "stock",
      "exchange": "NASDAQ",
      "country": "US",
      "currency": "USD"
    }
  ]
}
```

### Get asset detail

`GET /api/v1/assets/{assetId}`

Response includes asset metadata, linked themes, latest intelligence, latest score summary, and watchlist/holding status where available.

## 11. JSON API: Watchlist and Themes

### List watchlist items

`GET /api/v1/watchlist-items?status=active`

Response:

```json
{
  "watchlist_items": [
    {
      "id": "watchlist-item-uuid",
      "asset": {
        "symbol": "RKLB",
        "asset_type": "stock"
      },
      "item_type": "stock",
      "source_type": "newsletter",
      "reason_to_track": "Space economy exposure",
      "status": "active"
    }
  ]
}
```

### Create watchlist item

`POST /api/v1/watchlist-items`

Request:

```json
{
  "ticker": "RKLB",
  "item_type": "stock",
  "source_type": "newsletter",
  "source_reference": "Weekly space investing article",
  "reason_to_track": "Space economy exposure"
}
```

Response: created watchlist item.

### List themes

`GET /api/v1/themes?status=active`

Response:

```json
{
  "themes": [
    {
      "id": "theme-uuid",
      "name": "Space Economy",
      "theme_type": "technology",
      "creation_source": "manual",
      "status": "active"
    }
  ]
}
```

### Create theme

`POST /api/v1/themes`

Request:

```json
{
  "name": "Quantum Computing",
  "description": "Companies exposed to quantum hardware, software, and infrastructure.",
  "theme_type": "technology",
  "creation_source": "manual"
}
```

Response: created theme.

### Link asset to theme

`POST /api/v1/themes/{themeId}/assets`

Request:

```json
{
  "asset_id": "asset-uuid",
  "relationship_type": "core_exposure",
  "confidence": "medium"
}
```

Response: standard success envelope.

## 12. JSON API: Discover

### Get Discover results

`GET /api/v1/discover/results?portfolio_id={portfolioId}&theme=ai_infrastructure&risk_level=balanced`

Response:

```json
{
  "results": [
    {
      "asset": {
        "id": "asset-uuid",
        "symbol": "AVGO",
        "name": "Broadcom Inc.",
        "asset_type": "stock"
      },
      "discovery_source": "market_scanner",
      "label": "Research Further",
      "policy_status": "eligible",
      "sentiment_summary": "Positive news momentum, valuation requires review.",
      "risk_flags": [],
      "score_snapshot_id": "score-uuid"
    }
  ],
  "sections": {
    "market_scanner": 12,
    "hot_themes": 5,
    "sentiment_movers": 8,
    "speculative_radar": 3
  }
}
```

Discover may surface high-risk or policy-ineligible items, but they must be clearly labeled and should not receive positive action labels.

## 13. JSON API: Intelligence and Sentiment

### List intelligence items

`GET /api/v1/intelligence/items?asset_id={assetId}&theme_id={themeId}&limit=25`

Response:

```json
{
  "items": [
    {
      "id": "intelligence-item-uuid",
      "item_type": "news",
      "headline": "Example company announces major AI infrastructure deal",
      "summary": "Normalized short summary.",
      "source_name": "Provider or publisher",
      "source_url": "https://example.com/article",
      "published_at": "2026-08-08T00:00:00Z",
      "retrieved_at": "2026-08-08T00:05:00Z",
      "source_confidence": "medium"
    }
  ]
}
```

### Get sentiment summary

`GET /api/v1/intelligence/sentiment-summary?asset_id={assetId}&window=7d`

Response:

```json
{
  "asset_id": "asset-uuid",
  "window": "7d",
  "sentiment": {
    "news_score": 0.42,
    "social_score": 0.31,
    "combined_label": "positive",
    "confidence": "medium"
  },
  "signals": [
    {
      "signal_type": "news_sentiment",
      "sentiment_score": 0.42,
      "sentiment_label": "bullish",
      "confidence": "medium",
      "captured_at": "2026-08-08T00:05:00Z"
    }
  ]
}
```

## 14. JSON API: Scoring Engine

The Scoring Engine API returns structured scores. It does not produce buy/sell decisions.

### Score an asset

`POST /api/v1/scoring/assets/{assetId}/evaluate`

Request:

```json
{
  "portfolio_id": "portfolio-uuid",
  "policy_version_id": "policy-version-uuid",
  "score_version": "score-framework-v0.1",
  "include_sentiment": true,
  "include_technical_timing": true
}
```

Response:

```json
{
  "score_snapshot_id": "score-uuid",
  "asset": {
    "id": "asset-uuid",
    "symbol": "AAPL",
    "asset_type": "stock"
  },
  "score_version": "score-framework-v0.1",
  "policy_version_id": "policy-version-uuid",
  "scores": {
    "eligibility_gate": {
      "status": "eligible",
      "confidence": "medium"
    },
    "policy_fit": {
      "value": 76,
      "label": "fits with concentration watch",
      "confidence": "medium"
    },
    "quality": {
      "value": 82,
      "label": "strong",
      "confidence": "medium"
    },
    "valuation": {
      "value": 61,
      "label": "fair-to-expensive",
      "confidence": "medium"
    },
    "risk": {
      "value": 48,
      "label": "moderate",
      "confidence": "medium"
    },
    "sentiment_intelligence": {
      "value": 74,
      "label": "positive but watch hype",
      "confidence": "low"
    },
    "technical_timing": {
      "value": 58,
      "label": "extended",
      "confidence": "low"
    }
  },
  "supporting_signals": [],
  "conflicting_signals": [],
  "missing_evidence": [],
  "data_freshness": [],
  "generated_at": "2026-08-08T00:00:00Z"
}
```

## 15. JSON API: Policy Engine

### Get active policy

`GET /api/v1/policy-profiles/active?portfolio_id={portfolioId}`

Response:

```json
{
  "policy_profile": {
    "id": "policy-profile-uuid",
    "name": "Personal Investment Policy",
    "scope_type": "portfolio",
    "market_scope": "US",
    "jurisdiction_scope": "SG tax resident"
  },
  "active_version": {
    "id": "policy-version-uuid",
    "version_label": "policy-v0.3",
    "primary_benchmark": "NASDAQ_100_TR",
    "secondary_benchmark": "SP500_TR",
    "cash_target_percentage": 0.15,
    "satellite_max_percentage": 0.20,
    "drawdown_review_min_percentage": 0.15,
    "drawdown_review_max_percentage": 0.25
  }
}
```

### Evaluate policy

`POST /api/v1/policy/evaluate`

Request:

```json
{
  "portfolio_id": "portfolio-uuid",
  "asset_id": "asset-uuid",
  "policy_version_id": "policy-version-uuid"
}
```

Response:

```json
{
  "policy_status": "eligible_with_warnings",
  "warnings": [
    {
      "rule_key": "single_security_concentration",
      "severity": "warning",
      "message": "Holding is near configured concentration watch level."
    }
  ],
  "blockers": []
}
```

## 16. JSON API: Insights

Insights are non-execution attention records.

Allowed v1 labels:

- Track
- Research Further
- Criteria Approaching
- Risk Review
- Policy Warning
- Data Insufficient
- High-Risk Tracking

### List insights

`GET /api/v1/insights?portfolio_id={portfolioId}&status=active`

Response:

```json
{
  "insights": [
    {
      "id": "insight-uuid",
      "label": "Research Further",
      "title": "AVGO deserves deeper review",
      "summary": "Quality and intelligence signals are positive, but valuation should be reviewed.",
      "asset": {
        "symbol": "AVGO",
        "asset_type": "stock"
      },
      "score_snapshot_id": "score-uuid",
      "policy_version_id": "policy-version-uuid",
      "generated_at": "2026-08-08T00:00:00Z"
    }
  ]
}
```

### Generate insight from score

`POST /api/v1/insights/from-score/{scoreSnapshotId}`

Response:

```json
{
  "id": "insight-uuid",
  "label": "Research Further",
  "title": "AAPL deserves deeper review",
  "summary": "Generated from scoring and policy context.",
  "status": "active"
}
```

This endpoint must not generate buy, sell, reduce, add, hold, or execution-oriented language in v1.

## 17. JSON API: Provider and Endpoint Configuration

### List external endpoint configurations

`GET /api/v1/settings/external-endpoints`

Response:

```json
{
  "endpoints": [
    {
      "id": "endpoint-config-uuid",
      "name": "Finnhub News API",
      "endpoint_type": "provider_api",
      "provider_name": "finnhub",
      "environment": "production",
      "base_url": "https://finnhub.io/api/v1",
      "api_version": "v1",
      "auth_type": "api_key",
      "secret_reference": "FINNHUB_API_KEY",
      "timeout_ms": 5000,
      "enabled": true
    }
  ]
}
```

### Create or update endpoint configuration

`POST /api/v1/settings/external-endpoints`

Request:

```json
{
  "name": "Alpha Vantage API",
  "endpoint_type": "provider_api",
  "provider_name": "alpha_vantage",
  "environment": "production",
  "base_url": "https://www.alphavantage.co/query",
  "api_version": null,
  "auth_type": "api_key",
  "secret_reference": "ALPHA_VANTAGE_API_KEY",
  "timeout_ms": 5000,
  "retry_policy": {
    "max_attempts": 3,
    "backoff": "exponential"
  },
  "rate_limit_config": {
    "requests_per_minute": 5
  },
  "enabled": true
}
```

Response: created or updated endpoint configuration.

### List provider configurations

`GET /api/v1/settings/provider-configs`

Response:

```json
{
  "providers": [
    {
      "id": "provider-config-uuid",
      "endpoint_config_id": "endpoint-config-uuid",
      "provider_name": "finnhub",
      "provider_type": "news",
      "active_environment": "production",
      "enabled": true
    }
  ]
}
```

### Test provider configuration

`POST /api/v1/settings/provider-configs/{providerConfigId}/test`

Response:

```json
{
  "success": true,
  "message": "Provider test succeeded.",
  "data": {
    "provider_name": "finnhub",
    "latency_ms": 312,
    "checked_at": "2026-08-08T00:00:00Z"
  }
}
```

The response should never echo raw API keys or secrets.

## 18. JSON API: Advisor Chat

Advisor Chat is context-aware and evidence-bound. In v1 it should explain portfolio, watchlist, policy, scoring, and intelligence context. It should not execute trades or present itself as a regulated financial advisor.

### Get chat context summary

`GET /api/v1/advisor-chat/context?portfolio_id={portfolioId}`

Response:

```json
{
  "portfolio_id": "portfolio-uuid",
  "memory_enabled": true,
  "context": {
    "active_policy_version": "policy-v0.3",
    "portfolio_name": "US Portfolio",
    "primary_market_country": "US",
    "latest_insight_count": 4,
    "watchlist_item_count": 12,
    "latest_intelligence_window": "7d"
  }
}
```

### Send chat message

`POST /api/v1/advisor-chat/sessions/{sessionId}/messages`

Request:

```json
{
  "message": "Why is AVGO marked Research Further?",
  "portfolio_id": "portfolio-uuid",
  "linked_insight_id": "insight-uuid"
}
```

Response:

```json
{
  "session_id": "session-uuid",
  "message_id": "message-uuid",
  "response": "AVGO is marked Research Further because quality and intelligence signals are positive, but valuation and portfolio concentration need review.",
  "context_summary": {
    "used_policy_version": "policy-v0.3",
    "used_score_snapshot_id": "score-uuid",
    "used_intelligence_items": 3
  },
  "guardrails": [
    "No trade execution.",
    "No buy/sell label generated."
  ]
}
```

## 19. JSON API: Audit

### List audit events

`GET /api/v1/audit-events?entity_type=portfolio&entity_id={portfolioId}&limit=50`

Response:

```json
{
  "events": [
    {
      "id": "audit-event-uuid",
      "event_type": "holding_imported",
      "entity_type": "portfolio",
      "entity_id": "portfolio-uuid",
      "summary": "Imported 1 holding from JSON upload.",
      "created_at": "2026-08-08T00:00:00Z"
    }
  ]
}
```

## 20. Deferred APIs

These APIs are intentionally deferred:

- Registration APIs
- Login/logout APIs
- Email verification APIs
- Password reset APIs
- Public authentication provider integration APIs
- Broker import connection APIs
- Trade execution APIs
- Order ticket APIs
- Suitability questionnaire APIs for public advisory behavior
- Subscription/billing APIs
- External alert delivery APIs
- Full Recommendation Engine APIs
- Multi-user admin/role APIs

## 21. First Implementation Priority

Recommended first API implementation order:

1. `/api/v1/me`
2. `/api/v1/portfolios`
3. `/api/v1/portfolios/{portfolioId}/summary`
4. `/api/v1/portfolios/{portfolioId}/report-preferences`
5. `/api/v1/portfolios/{portfolioId}/report-visualizations`
6. `/api/v1/portfolios/{portfolioId}/holdings`
7. `/api/v1/portfolios/{portfolioId}/holding-imports/preview`
8. `/api/v1/portfolios/{portfolioId}/holding-imports/{batchId}/commit`
9. `/api/v1/watchlist-items`
10. `/api/v1/themes`
11. `/api/v1/settings/external-endpoints`
12. `/api/v1/settings/provider-configs`
13. `/api/v1/scoring/assets/{assetId}/evaluate` with mock scoring
14. `/api/v1/insights`
15. HTMX routes for the same workflows

This order creates a usable personal platform shell before real external data providers and AI integration are added.
