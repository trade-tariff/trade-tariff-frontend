# Trade Tariff Frontend Documentation

This directory is the starting point for understanding the Trade Tariff Frontend codebase. It is written for humans and AI coding tools that need a stable map before reading individual files.

## Start Here

- [Architecture](architecture/README.md) explains the main runtime boundaries and where to read the code.
- [Duty calculator architecture](architecture/duty-calculator.md) maps the import duty calculation journey, option construction, and high-risk decision points.
- [Development and delivery](development-and-delivery.md) summarises local setup, checks, PR, and deployment conventions.
- [Style guide](style-guide.md) covers Ruby/Rails, tests, GOV.UK Frontend components, and PR review expectations.
- [Search analytics](search-analytics.md) defines the GTM event properties and Amplitude survey setup.
- [AI-assisted search failure and fallback scenarios](https://github.com/trade-tariff/trade-tariff-backend/blob/main/docs/search-resilience.md) defines reduced guided-search outcomes, response failure codes and frontend warning policy. The backend repository owns this contract.
- [Code Wiki guide](code-wiki.md) explains how to use generated repository documentation safely.
- Existing domain notes: [Rules of Origin](../doc/rules_of_origin.md).

## Operational Entry Points

- [Puma request capacity metrics](puma-metrics.md) covers opt-in web worker occupancy, queue backlog and collection rollout.

- `README.md` covers local setup, backend configuration, assets, and test commands.
- `.env.development` contains local development defaults.
- `.github/workflows/ci.yml` shows the current lint, Brakeman, asset precompile, and RSpec checks.
- `.github/pull_request_template.md` is the current PR template and risk guide.
- `package.json` lists JavaScript, Sass, accessibility, and browser-test scripts.
- [Puma capacity dashboard](puma-capacity-dashboard.md) explains queue, spare-capacity and coverage views.

## AI Tooling Notes

AI tools should use this index before making code changes. Prefer source-backed claims and cite the relevant file paths in answers, reviews, and plans. When generated documentation disagrees with source code, treat source code, tests, and local docs as authoritative.

Shared tool entrypoints:

- `AGENTS.md` for Codex and other agentic coding tools.
- `CLAUDE.md` for Claude Code.
- `GEMINI.md` for Gemini CLI-style tools.
- `.github/copilot-instructions.md` for GitHub Copilot.
