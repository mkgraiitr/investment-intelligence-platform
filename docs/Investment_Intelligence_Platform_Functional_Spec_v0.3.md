# Investment Intelligence Platform

## Functional Specification v0.3

Prepared: 2026-08-08

Status: Current working specification

Note: This document is a product-planning artifact, not financial, legal, tax, or regulatory advice.

## 1. Product Overview

Investment Intelligence Platform is a personal portfolio intelligence and market research platform. The first version helps a user track holdings, monitor market intelligence, follow themes, review risk signals, inspect scores, and understand why an instrument or theme deserves attention.

The first release is for personal use, but the architecture should support future multi-user public use.

## 2. First-Cut Positioning

The first GitHub version should not behave as a regulated investment advisor.

It should focus on:

- Portfolio tracking
- Manual holdings input
- Market and news intelligence
- Watchlist and theme tracking
- Scoring framework
- Policy checks
- Explainability
- Advisor Chat context framework
- Audit and journal history

Explicit buy/sell recommendations, suitability logic, broker execution, and public advisory behavior are deferred.

## 3. Current Decisions

- Product name: Investment Intelligence Platform
- Build order: spec first
- Initial scope: personal use
- Future scope: public, multi-user platform
- Initial assets: US-listed stocks, ETFs, and cash
- Future assets: bonds, debt instruments, funds, REITs, crypto, private funds, custom assets
- Primary benchmark: Nasdaq-100 Total Return
- Secondary benchmark: S&P 500 Total Return
- Market data: Alpaca API or Alpha Vantage first
- News/sentiment: Finnhub News API first
- Social sentiment: ApeWisdom API or StockGeist first
- Brokerage import: deferred
- Manual holdings: page entry plus JSON upload
- Advisor Chat memory: user-controlled switch
- Themes: manual creation plus auto-suggestions
- Scoring Engine: separate API-based engine
- Recommendation Engine: deferred to later phase
- First implementation stack: HTMX, Spring Boot, Java 25, PostgreSQL
- Initial architecture style: modular monolith with clear engine and adapter boundaries
- Country/market-specific portfolios: stored as portfolios linked to an investor profile
- External provider endpoints: configurable through adapter settings, not hardcoded

## 4. Non-Goals for First Cut

The first version should not:

- Execute trades
- Generate broker order tickets
- Auto-buy or auto-sell
- Use labels like "Buy" or "Sell"
- Promise returns
- Provide public personalized financial advice
- Present social sentiment as enough evidence for portfolio action
- Give positive recommendations for shell-like, unsupported, or insufficient-evidence instruments

## 5. Primary Navigation

The product should include:

1. Home / Daily Brief
2. Portfolio
3. Discover
4. Watchlist & Themes
5. Research / Analysis Workspace
6. Insights
7. Intelligence
8. Policy & Settings

Discovery-oriented capabilities such as Market Scanner, Hot Themes, Sentiment Movers, and Speculative Radar should live inside Discover rather than appearing as separate primary navigation items.

Advisor Chat should be globally available, but in v1 it should explain context and evidence rather than produce final investment recommendations.

## 6. User & Profile Management

The system should separate:

- User
- Investor Profile
- Policy Profile
- Portfolio
- Brokerage Account
- User Preferences
- Advisor Chat Memory

For v1, only one user is required. For future public use, each user must have independent profile, policy, portfolio, watchlist, themes, insights, chat memory, and audit history.

Different country or market portfolios should be represented as separate portfolios linked to an investor profile. Investor profile should store personal/tax/risk context, while portfolio should store market scope, benchmark, base currency, and country-specific allocation context.

## 7. Manual Holdings Input

The Portfolio module should support:

- Add holding manually through a page
- Upload holdings using JSON
- Preview before import
- Validate required fields
- Flag duplicates
- Assign holdings to accounts
- Assign Core/Satellite classification
- Store import history

Required JSON format:

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

Future optional fields:

```json
{
  "ticker": "AAPL",
  "asset_type": "stock",
  "account_name": "Brokerage 1",
  "shares": 10.5,
  "avg_buy_price": 175.25,
  "purchase_date": "2026-03-15",
  "portfolio_bucket": "core",
  "currency": "USD",
  "notes": "Initial manual import"
}
```

## 8. Data Provider Strategy

The system should use provider adapters so APIs can be changed later.

Initial provider candidates:

- Market data: Alpaca API, Alpha Vantage
- News/sentiment: Finnhub News API
- Social sentiment: ApeWisdom API, StockGeist
- Benchmark/macroeconomic data: FRED, if needed
- Filings/fundamentals: SEC EDGAR APIs, if needed

Provider rules:

- No API keys checked into GitHub
- Use environment variables for secrets
- Keep provider base URLs and external endpoints configurable
- Support local, sandbox and production endpoint environments
- Store secret references, not raw secret values
- Store provider name and timestamp
- Track data freshness
- Track source confidence
- Allow mock/sample provider responses for local development

## 9. Scoring Engine

The Scoring Engine should be a separate modular engine.

It should calculate and return scores through an API response. It should not directly produce buy/sell recommendations.

Score categories:

- Eligibility Gate
- Policy Fit Score
- Quality Score
- Valuation Score
- Risk Score
- Sentiment & Intelligence Score
- Technical / Timing Score
- Confidence Score

Each score should include:

- Numeric value
- Plain-language label
- Confidence level
- Supporting signals
- Conflicting signals
- Missing evidence
- Data freshness
- Rule version

Scoring rules should be configurable and versioned. Exact formulas and thresholds can be designed later.

## 10. Insights Module

The first version should use safer insight labels instead of recommendation labels.

Allowed v1 labels:

- Track
- Research Further
- Criteria Approaching
- Risk Review
- Policy Warning
- Data Insufficient
- High-Risk Tracking

The Insights module should answer:

"What deserves attention, and why?"

It should not answer:

"What should I buy or sell?"

## 11. Policy Engine

The Policy Engine should evaluate portfolio and instrument context against user-defined rules.

Current policy defaults:

- Flexible cash target: 15%
- Satellite max: 20%
- Drawdown review range: 15%-25%
- Aspirational return target retained as personal context only
- Primary benchmark: Nasdaq-100 Total Return
- Secondary benchmark: S&P 500 Total Return
- Quality/liquidity-screened universe
- Speculative items appear only as High-Risk Tracking
- Shell-like or insufficient-evidence instruments cannot receive positive action labels

## 12. Intelligence Engine

The Intelligence Engine should collect and normalize:

- Market news
- Company news
- Announcements
- Deals and projects
- Investment articles
- Social sentiment
- Theme movement
- Sector narratives
- Hot opportunities
- Bubble/hype signals

It should connect intelligence items to:

- Portfolio holdings
- Watchlist items
- Themes
- Discover results
- Insights
- Advisor Chat explanations

## 13. Watchlist & Themes

The system should support tracking:

- Stocks
- ETFs
- Sectors
- Themes
- Technologies
- Company clusters
- News stories
- Deals/projects
- Custom ideas

Examples:

- Space economy
- Quantum computing
- Physical AI
- Robotics
- AI infrastructure
- Cybersecurity
- Nuclear energy
- Semiconductor equipment

Themes can be manually created and auto-suggested by the system.

## 14. Advisor Chat & Explainability

Advisor Chat should be context-aware and evidence-bound.

It should explain:

- Portfolio changes
- Scoring results
- Policy warnings
- Watchlist movement
- Theme movement
- News/sentiment impact
- Data freshness
- Supporting and conflicting signals

Memory should be controlled by a user switch.

Advisor Chat should not execute trades, override policy, or present itself as a regulated financial advisor.

## 15. Audit & Journal

The system should store:

- Manual imports
- Provider data timestamps
- Score snapshots
- Insight snapshots
- User notes
- Policy changes
- Watchlist changes
- Theme changes
- Advisor Chat saved insights
- Dismissed or archived items

## 16. Future Deferred Modules

Later versions may add:

- Full Recommendation Engine
- Suitability framework
- More exact scoring formulas
- Broker import integrations
- External alerts
- Public onboarding
- Subscription plans
- Multi-user roles
- Household/entity support
- Additional asset classes
- Regulatory review for public advisory behavior
