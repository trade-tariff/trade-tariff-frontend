# Contribute to Trade Tariff Frontend

Contributions to code, tests and documentation are welcome. Keep each change
focused on one user need or maintenance problem. Discuss large changes with the
maintainers before implementation. Be respectful and constructive in discussions.

## Report a bug or propose a change

Search [existing issues](https://github.com/trade-tariff/trade-tariff-frontend/issues)
and pull requests first. For a bug, include steps to reproduce it, the expected
result and the actual result. Use synthetic examples, not personal data or credentials.

Do not report vulnerabilities in public issues or pull requests. Follow
[HMRC's security reporting guidance](https://www.gov.uk/guidance/report-a-security-vulnerability-in-an-hmrc-online-service).

## Fork and branch

If you do not have write access, fork the repository on GitHub. Replace
`YOUR-USERNAME` below with the owner of your fork:

```sh
git clone git@github.com:YOUR-USERNAME/trade-tariff-frontend.git
cd trade-tariff-frontend
git remote add upstream git@github.com:trade-tariff/trade-tariff-frontend.git
git fetch upstream
git switch -c describe-your-change upstream/main
```

Maintainers can clone the upstream repository and create a branch from `main`.
Do not commit directly to `main`. Follow [README.md](README.md#run-locally) to set
up the application. A fork does not need production credentials.

## Make and check your change

- Follow the [repository style guide](docs/style-guide.md) and existing Rails, presenter, helper and test patterns.
- Add or update tests for changed behaviour and documentation for changed setup.
- Follow the [GOV.UK Design System](https://design-system.service.gov.uk/) for UI changes. Check keyboard navigation, focus, labels, errors, narrow screens and supported browsers. Automated checks do not replace manual accessibility checks.
- For browser accessibility tests, see [playwright.config.js](playwright.config.js) and the specs under `spec/javascript/accessibility/`. Run `BASE_URL=http://localhost:3001 yarn axxy` with the local application, backend data and Playwright browser dependencies available.
- Review the UK and Northern Ireland journeys affected by API, duty or measure changes.
- Write clear, task-focused content using the [GOV.UK style guide](https://guidance.publishing.service.gov.uk/writing-to-gov-uk-standards/style-guides/).
- Keep secrets, database dumps and personal data out of code, fixtures and screenshots.
- Run the [README checks](README.md#run-checks) before submitting your change.

Install [pre-commit](https://pre-commit.com/) and enable the repository hooks:

```sh
pre-commit install --hook-type pre-commit --hook-type pre-push
pre-commit run --all-files --hook-stage pre-commit
pre-commit run --all-files --hook-stage pre-push
```

The full hooks include infrastructure checks and can need additional tools or
private module access. See [.pre-commit-config.yaml](.pre-commit-config.yaml).
If a check is unavailable, say which one and why; do not claim it passed.

## Submit a pull request

1. Make small, logical commits. Use a conventional subject such as `docs: clarify local setup`. Put an existing Jira reference in the commit body, not the subject.
2. Push your branch to your fork: `git push -u origin describe-your-change`.
3. Open a pull request against this repository's `main` branch.
4. Complete the [pull request template](.github/pull_request_template.md). Explain the problem, the change and its risk in short, clear sentences.
5. Select one risk level using the template. Apply exactly one matching risk label if you have permission; otherwise ask a maintainer to apply it.
6. Respond to review comments and wait for required GitHub Actions checks and maintainer approval.

Fork pull requests do not receive repository secrets. Maintainers handle checks
that need privileged access; do not copy secrets to your fork or alter workflows
to bypass that restriction.

## Licence and reuse

Contributions must be compatible with the [MIT licence](LICENCE.md).
Keep existing copyright notices and identify the licence and source of any
third-party material you add. Reusing the code does not grant permission to
represent a fork as an official government service.
