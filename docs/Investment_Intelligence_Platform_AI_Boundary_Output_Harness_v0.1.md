# Investment Intelligence Platform

## AI Boundary and Output Harness v0.1

Prepared: 2026-08-09

Status: Initial AI boundary and harness baseline

## 1. Purpose

This document defines how AI should be introduced into the Investment Intelligence Platform.

The product should be built and deployed in two stages:

1. Traditional software engineering core
2. AI-assisted intelligence and explanation layer

The first deployed version should not depend on AI model calls. It should establish the deterministic product foundation first: portfolio tracking, holdings import, configurable reports, watchlist, themes, policy rules, scoring contracts, safe insights, endpoint configuration, and audit history.

AI should be added later through explicit modules, feature flags, and an output harness that validates AI output before it appears in the product.

## 2. Core Principle

AI output must be treated as untrusted draft intelligence until it passes validation.

```text
AI may summarize, classify, explain, and suggest.

AI must not be the source of truth.
AI must not execute actions.
AI must not silently override deterministic policy, scoring, user settings, or audit records.
```

## 3. Release Strategy

### Phase 1: Traditional Core Release

Phase 1 should be deployable without AI model access.

Included:

- Seeded personal user
- Portfolio setup
- Country/market-specific portfolio support
- Manual holdings entry
- JSON holdings upload preview and import
- Configurable portfolio report visualizations
- Watchlist and themes
- Policy Engine baseline
- Scoring Engine contract with deterministic or mock scoring
- Insights with safe rule-led labels
- Provider endpoint configuration
- Mock/manual intelligence records
- Audit and journal events
- Advisor Chat placeholder/context panel, without model-generated answers

Excluded:

- AI-generated chat responses
- AI-generated investment explanations
- AI-generated sentiment classification
- AI-generated theme suggestions
- AI-generated insight summaries
- Any model-based recommendation behavior

### Phase 2: AI-Assisted Layer

Phase 2 can add AI features after the core product is deployed and stable.

Candidate additions:

- Advisor Chat responses
- News/article summarization
- Announcement, deal, and project extraction
- Sentiment classification
- Theme clustering and auto-suggestions
- Explanation drafts for scores and policy warnings
- Insight summary generation
- Natural-language portfolio/report explanations

All Phase 2 AI output must pass through the AI Output Harness before being shown as approved product output.

## 4. Common AI Platform Layer

All AI calls should go through one common AI platform layer rather than being called directly from product modules.

The common layer should provide shared orchestration, provider routing, prompt management, context preparation, output validation, auditing, and evaluation.

```text
Traditional Application
  |
  v
Common AI Platform Layer
  |
  +-- Prompt Registry
  +-- Context Builder
  +-- Model Router
  +-- Tool / Context Access
  +-- AI Output Harness
  +-- Audit / Evaluation
  +-- Provider Adapters
  |
  v
Workflow-Specific AI Implementations
  |
  +-- advisor_chat
  +-- news_summary
  +-- sentiment_classification
  +-- theme_suggestion
  +-- insight_explanation
```

The first implementation can keep this as an internal module in the Spring Boot codebase. If AI traffic, cost, isolation, reuse, or workflow complexity grows, it can later be extracted into a separately deployed AI service.

Important rule: use a common platform layer, but avoid one generic free-form agent for every task. Each AI workflow should have its own prompt contract, allowed tools/context, output schema, validation rules, and audit requirements.

## 5. Traditional vs AI Responsibilities

| Area | Traditional engineering owns | AI may assist with |
|---|---|---|
| User & Profile | User records, preferences, seeded user, future auth hooks | Onboarding explanations later |
| Portfolio | Holdings, cash, allocation, concentration, benchmarks, reports | Plain-language explanations |
| Holdings Import | JSON parsing, validation, duplicate checks, persistence | Explaining validation errors |
| Policy Engine | Deterministic rules, eligibility gates, warnings, blockers | Explaining why a policy rule fired |
| Scoring Engine | Score contracts, score versions, deterministic calculations | Sentiment/intelligence input signals and explanations |
| Discover | Filters, screens, universe rules, eligibility display | Theme detection, narrative clustering |
| Watchlist & Themes | CRUD, source tracking, asset/theme links | Auto-suggested themes and summaries |
| Intelligence | Provider adapters, ingestion, timestamps, source links | Summaries, classification, sentiment |
| Insights | Safe labels, persistence, policy/scoring linkage | Human-readable explanation drafts |
| Advisor Chat | Context retrieval, permissions, memory switch, audit | Conversational responses |
| Audit & Journal | Immutable records and event history | Summaries of history |
| Provider Config | Endpoints, secrets, retries, rate limits | No AI needed |
| Common AI Platform Layer | Routing, prompt registry, context controls, validation, audit | Model/provider execution behind controlled workflows |

## 6. AI Output Harness

The AI Output Harness is the mandatory validation layer between model output and product output.

```text
Product Context
  |
  v
AI Prompt Builder
  |
  v
AI Model
  |
  v
AI Output Harness
  |
  +-- Schema Validator
  +-- Forbidden Language Checker
  +-- Label Whitelist Checker
  +-- Source Grounding Checker
  +-- Policy Guardrail Checker
  +-- Numeric Claim Checker
  +-- Confidence Normalizer
  +-- Audit Snapshot Writer
  |
  v
Approved UI Output / Rejected / Needs Review
```

No AI-generated content should be persisted as an approved insight, explanation, or chat response until it passes the harness.

## 7. Required AI Output Structure

AI responses used for product features should use structured output.

Example shape:

```json
{
  "output_type": "insight_explanation",
  "summary": "AAPL is worth further research because quality signals are strong, but valuation is not clearly attractive.",
  "label": "Research Further",
  "confidence": "medium",
  "supporting_signals": [
    {
      "type": "score",
      "reference_id": "score-snapshot-uuid",
      "summary": "Quality score is strong."
    }
  ],
  "conflicting_signals": [
    {
      "type": "valuation",
      "reference_id": "score-snapshot-uuid",
      "summary": "Valuation is fair-to-expensive."
    }
  ],
  "missing_evidence": [
    "Latest earnings transcript not available."
  ],
  "source_references": [
    {
      "source_type": "score_snapshot",
      "source_id": "score-snapshot-uuid"
    },
    {
      "source_type": "policy_version",
      "source_id": "policy-version-uuid"
    }
  ],
  "guardrail_notes": [
    "No buy/sell language used."
  ]
}
```

## 8. Forbidden Output in v1/v2

AI output must not contain:

- Buy
- Sell
- Strong Buy
- Strong Sell
- Hold
- Reduce
- Add
- Target Price
- Price target
- Guaranteed return
- Must buy
- Must sell
- Order
- Trade now
- Execute

The forbidden-language list should be configurable and versioned.

## 9. Allowed Insight Labels

AI must not create new insight labels outside the approved v1 list.

Allowed labels:

- Track
- Research Further
- Criteria Approaching
- Risk Review
- Policy Warning
- Data Insufficient
- High-Risk Tracking

If AI output cannot be confidently mapped to one of these labels, the harness should reject it or downgrade it to Data Insufficient.

## 10. Grounding Rules

AI claims must be grounded in known system context.

Allowed evidence sources:

- Portfolio holdings
- Watchlist items
- Themes
- Policy versions
- Policy rules
- Score snapshots
- Score components
- Intelligence items
- Sentiment signals
- Provider fetch metadata
- User notes
- Audit events

Grounding requirements:

- Every material claim should reference at least one known source.
- Unsupported claims should be removed or marked as missing evidence.
- Source freshness should be visible when relevant.
- If source confidence is low, output confidence should not be high.

## 11. Policy Override Rules

The Policy Engine always wins over AI wording.

Examples:

- If the Policy Engine marks an asset ineligible, AI cannot label it Research Further as a positive candidate.
- If evidence is insufficient, AI cannot upgrade the output to a positive-sounding label.
- If a security is shell-like or unsupported, AI cannot produce a favorable action-oriented summary.
- If AI sentiment is positive but policy risk is high, the output should reflect the warning.

## 12. Confidence Handling

AI confidence should be normalized by the harness.

Inputs:

- Model self-reported confidence
- Number and quality of supporting sources
- Conflicting evidence count
- Missing evidence
- Source freshness
- Provider confidence
- Policy warnings

Rules:

- Missing evidence lowers confidence.
- Stale data lowers confidence.
- Conflicting evidence lowers confidence.
- Low-quality sources cap confidence.
- Policy warnings cap or override confidence.

## 13. Audit Requirements

AI-related actions should be auditable when Phase 2 begins.

Audit metadata should include:

- Feature that invoked AI
- Model provider
- Model name
- Prompt/context summary
- Output type
- Raw structured output, if retention is allowed
- Validation result
- Rejection reasons, if any
- Policy version
- Score version
- Source references
- Timestamp

Raw prompts and raw model responses may contain sensitive information. Retention should be configurable before public use.

## 14. Feature Flags

AI features should be controlled by feature flags.

Suggested flags:

- `ai.enabled`
- `ai.advisor_chat.enabled`
- `ai.news_summarization.enabled`
- `ai.sentiment_classification.enabled`
- `ai.theme_suggestions.enabled`
- `ai.insight_explanations.enabled`
- `ai.output_harness.strict_mode`

Default for Phase 1:

```text
ai.enabled = false
```

## 15. Phase 1 Placeholder Behavior

In the traditional core release:

- Advisor Chat may show a placeholder panel.
- The app may display deterministic explanations from policy/scoring data.
- No external AI provider is required.
- AI provider endpoint configuration may exist but should be disabled.
- AI routes should either be absent, disabled, or return a clear "AI features are not enabled" response.

Example disabled response:

```json
{
  "success": false,
  "error": {
    "code": "AI_FEATURE_DISABLED",
    "message": "AI features are not enabled in this deployment."
  }
}
```

## 16. Future Database Additions

The current database model already supports many explainability needs through score snapshots, insights, chat messages, and audit events.

When AI is added, consider these additional tables:

- `ai_model_invocations`
- `ai_output_validation_results`
- `ai_prompt_templates`
- `ai_feature_flags`
- `ai_memory_entries`

These should not be required for the first traditional core deployment.

## 17. Future API Additions

The first API contract may include Advisor Chat placeholders, but AI-generating endpoints should remain disabled until Phase 2.

Future AI APIs may include:

- Generate AI-assisted insight explanation
- Summarize intelligence items
- Classify sentiment
- Suggest themes
- Explain portfolio report changes
- Ask Advisor Chat
- Validate AI output through harness

## 18. Success Criteria

Before enabling AI features:

- Traditional core is deployed and stable.
- Policy Engine is deterministic.
- Scoring Engine contract is stable.
- Insight labels are constrained.
- Audit events are working.
- External endpoint configuration is working.
- AI output schema is validated.
- Forbidden language checker is implemented.
- Policy override behavior is tested.
- AI feature flags are in place.

## 19. Non-Negotiable Guardrails

- No AI-driven trade execution.
- No AI-generated buy/sell labels in v1/v2.
- No AI output without schema validation.
- No AI output without source grounding for material claims.
- No AI output overriding Policy Engine.
- No hidden AI memory; memory must be user-controlled.
- No raw secrets in prompts.
- No raw API keys in model context.
