# Trade Tariff Frontend Documentation

This directory is the starting point for understanding the Trade Tariff Frontend codebase. It is written for humans and AI coding tools that need a stable map before reading individual files.

## Start Here

- [Architecture](architecture/README.md) explains the main runtime boundaries and where to read the code.
- [Development and delivery](development-and-delivery.md) summarises local setup, checks, PR, and deployment conventions.
- [Style guide](style-guide.md) covers Ruby/Rails, tests, GOV.UK Frontend components, and PR review expectations.
- [Code Wiki guide](code-wiki.md) explains how to use generated repository documentation safely.
- Existing domain notes: [Rules of Origin](../doc/rules_of_origin.md).

## Operational Entry Points

- `README.md` covers local setup, backend configuration, assets, and test commands.
- `.env.development` contains local development defaults.
- `.github/workflows/ci.yml` shows the current lint, Brakeman, asset precompile, and RSpec checks.
- `.github/pull_request_template.md` is the current PR template and risk guide.
- `package.json` lists JavaScript, Sass, accessibility, and browser-test scripts.

## AI Tooling Notes

AI tools should use this index before making code changes. Prefer source-backed claims and cite the relevant file paths in answers, reviews, and plans. When generated documentation disagrees with source code, treat source code, tests, and local docs as authoritative.

Shared tool entrypoints:

- `AGENTS.md` for Codex and other agentic coding tools.
- `CLAUDE.md` for Claude Code.
- `GEMINI.md` for Gemini CLI-style tools.
- `.github/copilot-instructions.md` for GitHub Copilot.
