# Accessibility Testing & HTML Report

This project integrates **Playwright** with **axe-core** to automate accessibility testing and generate a browsable HTML report.

---

## ✅ Features

- Runs automated a11y checks using Playwright and axe-core
- Saves results in both JSON and HTML formats
- Stores the HTML report in the `public/` directory
- (Optional) Publishes the report to GitHub Pages
- (Optional) Shares the report link on Slack

---

## 🧪 Running Accessibility Tests Locally

1. **Install dependencies**:

   ```bash
   npm install

   ```

2. Run the test:

npx playwright test

3. View the report:

After running the test, open:

📊 About the Accessibility Report
The HTML report includes:

Total violations found on the tested page

Grouping by severity:

critical (🔴)

serious (🟠)

moderate (🟡)

minor (🟢)

For each issue:

Short description

Link to the relevant axe-core documentation

HTML snippet of the problematic element

CSS selector for easy identification in the codebase

🔍 Sample Issue Displayed
php-template

SERIOUS Issue (1)
❌ <li> elements must be contained in a <ul> or <ol>

Description: Ensure <li> elements are used semantically  
Help: https://dequeuniversity.com/rules/axe/4.10/listitem?application=playwright

Element HTML: <li class="govuk-footer__inline-list-item">Yes</li>  
Selector: .govuk-footer**meta-item--grow > .govuk-footer**inline-list-item:nth-child(2)

👨‍💻 For Developers
To fix issues:

Locate the selector in your codebase.

Read the description and refer to the provided documentation link.

Apply appropriate semantic HTML or ARIA attributes as recommended.

Rerun the test to confirm the fix.

public/accessibility-report.html

🌍 Publishing the Report to GitHub Pages

You need to configure your repo to use GitHub Pages (Settings → Pages → Source: gh-pages branch)

1. Install gh-pages:

npm install --save-dev gh-pages

2. Update package.json:
   json

"scripts": {
"deploy-report": "gh-pages -d public"
}

3. Deploy manually:

   npm run deploy-report

4. Access your report:
   php-template

https://<your-github-username>.github.io/<our-repo-name>/accessibility-report.html

⚙️ CI/CD: Automate with GitHub Actions (Optional)

Create .github/workflows/accessibility-report.yml:

yaml

name: Accessibility Report

on:
push:
branches: [main]

jobs:
build-and-deploy:
runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Node
        uses: actions/setup-node@v3
        with:
          node-version: 20

      - run: npm ci

      - name: Run accessibility tests
        run: npx playwright test

      - name: Deploy report to GitHub Pages
        run: npm run deploy-report

💬 Share the Report in Slack (Optional)
1, Set up an Incoming Webhook in your Slack workspace.

    2,Add a new step to your GitHub Action:

yaml

      - name: Notify Slack
        run: |
          curl -X POST -H 'Content-type: application/json' \
          --data '{"text":"New accessibility report: https://<your-username>.github.io/<repo-name>/accessibility-report.html"}' \
          ${{ secrets.SLACK_WEBHOOK_URL }}

📁 File Structure

├── axe-reports/
│ └── report-latest.json #Raw json from axe-core
├── public/
│ └── accessibility-report.html # -readable report
├── utils/
│ └── generate-html-report.js #Report builderscript
├── spec/
│ └── javascript/accessibility/
│ └── accessibility.spec.js #Playwright a11y test

Notes :
Reports are regenerated with every test run.

The HTML report is safe to commit or ignore (depending on workflow).

Consider a .gitignore rule if you don't wish to commit

the report:

/public/accessibility-report.html
