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
- Traditional-core-first delivery strategy, with AI-assisted features added later
- Country/market-specific portfolio support through portfolio configuration
- Configurable portfolio report visualizations
- Configurable external endpoint/provider settings
- Audit and journal history

## Deferred Scope

- Full recommendation engine
- Suitability framework
- Broker import integrations
- Trade execution
- AI-generated responses and AI-assisted intelligence features in the first deployed core version
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
- `Investment_Intelligence_Platform_AI_Boundary_Output_Harness_v0.1.md`

Version `v0.3` is the current functional baseline. Version `Technical Architecture v0.1` is the current implementation baseline. Version `Database Model v0.1` is the current logical data baseline. Version `API Contract v0.1` is the current backend/API baseline. Version `AI Boundary and Output Harness v0.1` is the current AI safety and integration baseline.

## Selected Technical Stack

The first implementation will use:

- Frontend interaction model: HTMX
- Backend: Spring Boot 4.1.x
- Java runtime: Java 25
- Build tool: Maven
- Database: PostgreSQL
- Initial architecture style: modular monolith with clear engine and adapter boundaries

Spring Boot 4.1.x is the recommended baseline for Java 25. Spring Boot 3.5.x can be treated as a fallback only if a required library is not yet compatible with Spring Boot 4.x.

## How to Run

Phase 1 is a traditional-core build. It starts the app shell, database schema, seeded personal portfolio, policy placeholders, configurable provider settings, and non-AI portfolio views.

### Prerequisites

- Java 25, preferably Eclipse Temurin 25
- Maven 3.9+
- Docker Desktop
- IntelliJ IDEA
- PostgreSQL client tools, optional but useful for inspection

### IntelliJ Setup

Open this folder in IntelliJ:

```text
/Users/home/IdeaProjects/investment-intelligence-platform
```

Let IntelliJ import it as a Maven project.

Then configure Java:

1. Open `File → Project Structure → Project`.
2. Set `Project SDK` to `Temurin 25`.
3. Set `Language level` to `25`.
4. Open `Settings → Build, Execution, Deployment → Build Tools → Maven → Runner`.
5. Set `JRE` to `Project JDK` or `Temurin 25`.

### Build and Test from IntelliJ

In the Maven panel, run:

```text
Lifecycle → test
```

The current Phase 1 build should pass the unit tests.

### Start PostgreSQL

From the IntelliJ Terminal:

```bash
docker compose up -d postgres
```

Check that the container is running:

```bash
docker compose ps
```

Confirm PostgreSQL is ready:

```bash
docker compose exec postgres pg_isready -U investment -d investment_intelligence
```

Expected output:

```text
/var/run/postgresql:5432 - accepting connections
```

### Run the Spring Boot App from IntelliJ

Open:

```text
src/main/java/com/mkgraiitr/investmentintelligence/InvestmentIntelligenceApplication.java
```

Click the green Run button beside the `main` method.

You should see output similar to:

```text
Tomcat started on port 8080
Started InvestmentIntelligenceApplication
```

### Open in Browser

```text
http://localhost:8080
```

Useful pages:

- `http://localhost:8080/app/home`
- `http://localhost:8080/app/portfolio`
- `http://localhost:8080/app/discover`
- `http://localhost:8080/app/watchlist`
- `http://localhost:8080/app/insights`
- `http://localhost:8080/app/policy-settings`

### Stop the App

In IntelliJ, stop the Spring Boot run configuration.

Then stop PostgreSQL:

```bash
docker compose stop postgres
```

### Terminal Alternative

If you prefer terminal-only execution:

```bash
cd /Users/home/IdeaProjects/investment-intelligence-platform
docker compose up -d postgres
env JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home mvn test
env JAVA_HOME=/Library/Java/JavaVirtualMachines/temurin-25.jdk/Contents/Home mvn spring-boot:run
```

AI features are disabled by default in Phase 1:

```yaml
ai:
  enabled: false
  advisor-chat:
    enabled: false
```

## Delivery Strategy

The first deployable version should focus on the traditional software engineering core. AI-assisted features should be added only after the deterministic product foundation is stable and deployed.

Phase 1 should not require AI model access. Phase 2 can add Advisor Chat responses, AI-assisted summaries, sentiment classification, theme suggestions, and explanation drafts through a common AI Platform Layer and the AI Output Harness.

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
