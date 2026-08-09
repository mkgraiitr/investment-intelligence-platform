# Investment Intelligence Platform

Investment Intelligence Platform is a personal portfolio intelligence and market research project. The first cut focuses on portfolio tracking, manual holdings input, market intelligence, watchlist and theme tracking, scoring-framework design, policy checks, explainability, and audit history.

The first GitHub version intentionally does not implement buy/sell recommendations, brokerage execution, or regulated advisory behavior. Those are deferred until the framework, compliance posture, and recommendation logic are designed separately.

## Current Scope

- Manual portfolio input
- JSON holdings upload format
- Stocks, ETFs, and cash as initial asset types
- Watchlist and theme tracking
- Market, news, and social sentiment provider adapter planning
- Scoring Engine API contract
- Policy Engine framework
- Insights module with safer attention labels
- Advisor Chat context and explainability framework
- Country/market-specific portfolio support through portfolio configuration
- Configurable portfolio report visualizations
- Configurable external endpoint/provider settings
- Audit and journal history

## Deferred Scope

- Full recommendation engine
- Suitability framework
- Broker import integrations
- Trade execution
- User registration, login, and public authentication flows
- Public advisory behavior
- External alerts
- Additional asset classes

## Product Specification

The working specification history is stored in `docs/`:

- `Investment_Intelligence_Platform_Functional_Spec_v0.3.md`
- `Investment_Intelligence_Platform_Technical_Architecture_v0.1.md`
- `Investment_Intelligence_Platform_Database_Model_v0.1.md`
- `Investment_Intelligence_Platform_API_Contract_v0.1.md`

Version `v0.3` is the current functional baseline. Version `Technical Architecture v0.1` is the current implementation baseline. Version `Database Model v0.1` is the current logical data baseline. Version `API Contract v0.1` is the current backend/API baseline.

## Selected Technical Stack

The first implementation will use:

- Frontend interaction model: HTMX
- Backend: Spring Boot
- Java runtime: Java 25
- Database: PostgreSQL
- Initial architecture style: modular monolith with clear engine and adapter boundaries

## Product Design

The current Figma design file is available here:

- [Investment Intelligence Platform design](https://www.figma.com/design/GkDt0X80N7EwQU20GttFUQ)

## Main Pages

| Menu item | Description |
|---|---|
| Home / Daily Brief | A configurable landing page that summarizes today’s portfolio status, market signals, alerts, and items needing attention. |
| Portfolio | Shows holdings, allocation, cash level, concentration, benchmark comparison, and policy-aware portfolio risk. |
| Discover | Helps find stocks, ETFs, sectors, themes, sentiment movers, announcements, and market ideas worth tracking. |
| Watchlist & Themes | Stores stocks or themes of interest, including ideas from articles, friends, newsletters, social buzz, or personal research. |
| Research / Analysis Workspace | Provides a deeper workspace for studying one stock, ETF, sector, or theme using fundamentals, valuation, sentiment, risks, and explainability. |
| Insights | Converts analysis into non-execution guidance such as Track, Research Further, Criteria Approaching, Risk Review, or Policy Warning. |
| Intelligence | Centralizes news, sentiment, big announcements, deals, projects, social signals, and market narratives affecting tracked assets. |
| Policy & Settings | Manages investment policy, benchmark, cash preference, risk thresholds, scoring rules, data providers, profile, and future public-ready settings. |

Terminology baseline:

- **Discover** is the primary navigation item for finding market ideas. **Market Scanner** is a section inside Discover.
- **Research / Analysis Workspace** is the deeper workspace for studying a specific asset, sector, or theme.
- **Insights** is the safer v1 replacement for action-oriented recommendation language.

## Authentication Direction

The first build will run in personal/local mode with one seeded user. User registration, login, email verification, password reset, and public authentication flows are deferred, but the schema and module boundaries are multi-user-ready.

## Portfolio Report Visualizations

Portfolio reports should support configurable visualizations. Users should be able to show, hide, reorder, and choose chart types for portfolio views such as Core/Satellite/Cash, sector allocation, country/market exposure, currency exposure, theme exposure, account allocation, and holding concentration.

## Manual Holdings Format

The initial import format is a JSON array:

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

See `samples/holdings.sample.json`.

## Provider Direction

Initial provider candidates:

- Market data: Alpaca API or Alpha Vantage
- News/sentiment: Finnhub News API
- Social sentiment: ApeWisdom API or StockGeist
- Benchmark/macroeconomic data: FRED, if needed
- Filings/fundamentals: SEC EDGAR APIs, if needed

API keys should be provided through environment variables and should never be committed.

Provider base URLs and other external endpoints should be configurable through adapter settings rather than hardcoded in application code.

## Document Generation

The Word spec documents were generated from Markdown sources with:

```bash
python3 tools/build_spec_documents.py
```

The generated QA render images are intentionally ignored by Git.

## Disclaimer

This project is a product-planning and software-development artifact. It is not financial, legal, tax, or regulatory advice.
