# Investment Intelligence Platform

## Technical Architecture v0.1

Prepared: 2026-08-08

Status: Initial technical architecture baseline

## 1. Architecture Decision

The first implementation will use:

- Frontend interaction model: HTMX
- Backend: Spring Boot 4.1.x
- Language/runtime: Java 25
- Build tool: Maven
- Database: PostgreSQL

Spring Boot 4.1.x is the recommended baseline for Java 25. Spring Boot 3.5.x can be treated as a fallback only if a required library is not yet compatible with Spring Boot 4.x.

The application should start as a modular monolith: one deployable backend with clear internal module boundaries. This keeps the first version simple to build and run while preserving the option to extract engines or services later.

## 2. Architecture Principles

- Keep modules independent and replaceable.
- Prefer server-rendered screens with HTMX-driven interactions over a large single-page frontend.
- Treat external data providers as adapters, not core business logic.
- Treat external provider endpoints as configurable settings, not hardcoded application constants.
- Keep scoring rules configurable and versioned.
- Keep policy checks separate from scoring calculations.
- Keep insights separate from buy/sell recommendations.
- Build and deploy the traditional core before enabling AI-assisted features.
- Store enough audit history to explain why a score, insight, or warning appeared.
- Design for one personal user first, but avoid assumptions that prevent future multi-user use.

## 3. High-Level Application Shape

```text
Browser
  |
  | HTML + HTMX requests
  v
Spring Boot Web Application
  |
  +-- Web/UI Layer
  +-- Application Services
  +-- Domain Modules
  +-- Provider Adapters
  +-- Persistence Layer
  |
  v
PostgreSQL

External Providers
  |
  +-- Market data: Alpaca API / Alpha Vantage
  +-- News sentiment: Finnhub
  +-- Social sentiment: ApeWisdom / StockGeist
  +-- Filings/fundamentals: SEC EDGAR, if needed
```

AI providers are intentionally not required for the first deployed core release. AI integrations should be added later through feature flags, configurable endpoints, and the AI Output Harness.

## 4. Frontend Architecture

The frontend should be server-rendered with focused HTMX interactions.

Recommended frontend stack:

- HTMX for partial page updates
- Thymeleaf or JTE for server-side templates
- Tailwind CSS or Bootstrap for styling
- Small JavaScript libraries only where needed for charts, tables, or rich visualizations

Recommended first choice:

- Thymeleaf for the first build because it is simple, common in Spring Boot, and easy to reason about.
- Tailwind CSS if visual flexibility is important.
- Bootstrap if speed and ready-made components are more important.

HTMX should be used for:

- Portfolio table refresh
- Portfolio report chart refresh
- Holdings add/edit/delete forms
- JSON upload preview and validation
- Watchlist item creation
- Theme filters
- Discover screen filters
- Insight status updates
- Policy setting edits
- Advisor Chat panel updates

Avoid turning the frontend into a hidden SPA. If a screen becomes highly interactive later, it can use a small embedded JavaScript component without changing the whole architecture.

## 5. Backend Architecture

The backend should use Spring Boot with a layered modular structure:

```text
src/main/java/.../investmentintelligence
  |
  +-- app
  |   +-- web
  |   +-- config
  |   +-- security
  |
  +-- user
  +-- portfolio
  +-- asset
  +-- watchlist
  +-- theme
  +-- intelligence
  +-- scoring
  +-- policy
  +-- insight
  +-- advisorchat
  +-- ai
  +-- audit
  |
  +-- provider
      +-- marketdata
      +-- news
      +-- socialsentiment
      +-- filings
```

Each module should own its domain model, application services, repository interfaces, and module-specific DTOs.

## 6. Core Modules

| Module | Responsibility |
|---|---|
| User & Profile | Stores user identity, preferences, profile, and future multi-user readiness. |
| Portfolio | Manages holdings, cash, account grouping, allocation, concentration, benchmark comparison, and configurable report visualizations. |
| Asset | Stores normalized asset metadata for stocks, ETFs, and future asset types. |
| Watchlist | Tracks ideas from articles, friends, newsletters, social buzz, and personal research. |
| Theme | Tracks sectors, technologies, narratives, and custom investment themes. |
| Intelligence | Collects and normalizes news, announcements, deals, projects, articles, and sentiment. |
| Scoring Engine | Produces modular score responses for quality, valuation, risk, sentiment, policy fit, and confidence. |
| Policy Engine | Evaluates user-defined rules, cash preference, concentration warnings, benchmark, and eligibility gates. |
| Insights | Converts analysis into safe attention labels such as Track, Research Further, Risk Review, and Policy Warning. |
| Advisor Chat | Provides context-aware explanations using portfolio, watchlist, policy, intelligence, and scoring history. |
| AI Platform Layer | Future common module for AI workflow routing, prompt registry, context building, output harness validation, model/provider adapters, and audit/evaluation. |
| Audit & Journal | Records imports, score snapshots, policy changes, insight changes, and important user actions. |
| Provider Adapters | Integrates external APIs while keeping provider-specific logic outside the domain modules. |

For v1, User & Profile should run in personal/local mode with one seeded user. Registration, login, email verification, password reset, and public authentication provider integration are deferred, but the module should keep user ownership explicit so those features can be added later.

## 7. Scoring Engine Boundary

The Scoring Engine should be a separate internal module with an API-style contract, even if it runs inside the same Spring Boot application at first.

It should accept structured input and return structured score output.

Example response shape:

```json
{
  "asset": {
    "symbol": "AAPL",
    "asset_type": "stock"
  },
  "score_version": "score-framework-v0.1",
  "scores": {
    "eligibility_gate": {
      "status": "eligible",
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
    }
  },
  "supporting_signals": [],
  "conflicting_signals": [],
  "missing_evidence": [],
  "data_freshness": [],
  "generated_at": "2026-08-08T00:00:00Z"
}
```

Exact scoring formulas remain deferred. The first priority is a stable, explainable contract.

## 8. Data Model Baseline

The current logical data model is defined in:

- `Investment_Intelligence_Platform_Database_Model_v0.1.md`

PostgreSQL should be the source of truth. Provider responses may be cached in normalized tables where useful. The first schema should support personal use while preserving future multi-user, multi-portfolio, and additional-asset-class expansion.

## 9. Provider Adapter Strategy

Provider adapters should expose internal interfaces such as:

- MarketDataProvider
- NewsProvider
- SocialSentimentProvider
- FundamentalsProvider
- BenchmarkProvider

This allows Alpaca, Alpha Vantage, Finnhub, ApeWisdom, StockGeist, or future providers to be replaced without rewriting product logic.

Provider adapters should read endpoint details from configuration rather than hardcoding URLs. This applies to market data APIs, news APIs, social sentiment APIs, broker APIs, AI model endpoints, future alert webhooks, and any other external endpoint.

Endpoint configuration should support:

- Provider name
- Provider type
- Environment: local, sandbox, production
- Base URL
- API version
- Authentication type
- Secret reference name, not the raw secret
- Timeout settings
- Retry/backoff settings
- Rate-limit settings
- Enabled/disabled flag

Provider adapter responses should include:

- provider name
- retrieval timestamp
- source timestamp, if available
- confidence or quality metadata
- raw reference ID or URL, where allowed
- normalized response payload

API keys and other secrets must come from environment variables, a local configuration file excluded from Git, or a future secret manager. Raw secrets should not be stored in source code or committed configuration.

## 10. Initial Page-to-Module Mapping

| Page | Primary backend modules |
|---|---|
| Home / Daily Brief | Portfolio, Intelligence, Insights, Policy, Advisor Chat |
| Portfolio | Portfolio, Asset, Policy, Audit |
| Discover | Asset, Intelligence, Scoring, Policy, Watchlist |
| Watchlist & Themes | Watchlist, Theme, Intelligence, Audit |
| Research / Analysis Workspace | Asset, Intelligence, Scoring, Policy, Insights, Advisor Chat |
| Insights | Insights, Scoring, Policy, Audit |
| Intelligence | Intelligence, Provider Adapters, Sentiment |
| Policy & Settings | User, Profile, Policy, Provider Configuration, Audit |

## 11. API Contract Baseline

The current API contract is defined in:

- `Investment_Intelligence_Platform_API_Contract_v0.1.md`

The first implementation should separate server-rendered page routes, HTMX fragment routes, and JSON API routes. JSON APIs should be used for domain data, engine contracts, provider adapters, imports, and future integration points.

## 12. AI Boundary Baseline

The current AI boundary and output validation approach is defined in:

- `Investment_Intelligence_Platform_AI_Boundary_Output_Harness_v0.1.md`

The first deployed version should not depend on AI model calls. AI-assisted features should be added later behind feature flags and routed through a common AI Platform Layer and the AI Output Harness.

## 13. First MVP Build Order

Recommended build sequence:

1. Project scaffold: Spring Boot 4.1.x, Java 25, Maven, PostgreSQL, HTMX, templates, base layout
2. Seeded user/profile placeholder for personal mode
3. Manual holdings entry
4. JSON holdings upload preview and import
5. Portfolio holdings and allocation view
6. Watchlist & Themes page
7. Provider adapter interfaces with mock providers
8. Intelligence item model and manual/mock ingestion
9. Scoring Engine contract with mock scoring
10. Insights page using safe v1 labels
11. Policy settings baseline
12. Advisor Chat context placeholder, with AI disabled
13. Audit event capture
14. Deploy traditional core release
15. Add AI-assisted features later through the AI Output Harness

## 14. Deferred Technical Decisions

These decisions should be made later:

- Thymeleaf vs JTE final template engine
- Tailwind CSS vs Bootstrap final styling framework
- Exact Spring Boot 4.1.x patch version at scaffold time
- Authentication provider for public version
- Registration, login, email verification, and password reset flows
- Exact Scoring Engine formulas and thresholds
- Whether Scoring Engine becomes a separate service
- Whether Advisor Chat uses OpenAI, local models, or multiple providers
- AI Output Harness implementation details
- Background job framework
- Deployment target
- External alert channels
- Broker import architecture

## 15. Security and Compliance Guardrails

The first implementation should:

- Avoid buy/sell labels.
- Avoid execution workflows.
- Keep all insights evidence-bound.
- Keep user policy separate from system-generated analysis.
- Log score and policy versions.
- Store source timestamps and provider names.
- Never commit secrets.
- Keep Advisor Chat memory user-controlled.
- Keep AI features disabled until output validation, grounding, policy override, and audit behavior are implemented.

## 16. Near-Term Deliverables

Next documents or implementation artifacts:

- Spring Boot project scaffold
- HTMX page shell
- Mock provider interfaces
- Manual holdings import flow
