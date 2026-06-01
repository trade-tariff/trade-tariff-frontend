# Google Code Wiki

[Google Code Wiki](https://codewiki.google/) is a hosted public-preview tool that generates structured documentation for public repositories. It can help map unfamiliar code, but it is not authoritative.

Use it as an exploration aid for this repository:

- Open `https://codewiki.google/`.
- Search for or import `trade-tariff/trade-tariff-frontend`.
- Use generated pages and chat answers to find candidate files and concepts.
- Verify important claims against this repository before making changes.

## What To Trust

Good Code Wiki use cases:

- Getting a first-pass map of unfamiliar code.
- Finding likely entry points for a feature area.
- Asking high-level questions before reading source files.
- Comparing generated diagrams with local architecture docs.

Do not treat generated output as authoritative for:

- legally significant tariff content
- measure, duty, quota, certificate, rules of origin, or Green Lanes behaviour
- backend API contracts and error semantics
- security, auth, cookies, and secret-handling behaviour
- accessibility compliance or GOV.UK Design System conformance
- production operations or rollback instructions

For those areas, verify against source code, tests, local docs, backend API docs, and GitHub Actions.

## Local Verification Anchors

Start with:

- [Documentation index](README.md)
- [Architecture index](architecture/README.md)
- [Style guide](style-guide.md)
- `config/routes.rb`
- `app/controllers/`
- `app/models/`
- `app/forms/`
- `app/presenters/`
- `app/helpers/`
- `app/views/`
- `app/assets/stylesheets/`
- `app/javascript/`
- `spec/`

## Keeping Local Docs Useful

When changing a subsystem, update the smallest relevant doc page. Prefer linking to existing docs over copying long explanations. If Code Wiki gives a useful generated explanation, convert only the verified, stable parts into local docs.
