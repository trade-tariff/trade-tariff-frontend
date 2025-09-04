const { test, expect } = require("@playwright/test");
const AxeBuilder = require("@axe-core/playwright").default;
const { LoginPage } = require("./pages/loginPage");
const { generateHtmlReport } = require("./utils/generateHtmlReport");
const fs = require("fs");
const path = require("path");

test.describe.configure({ mode: 'serial' });

const configPath = path.join(__dirname, 'config.json');
const testConfig = JSON.parse(fs.readFileSync(configPath, 'utf8'));
const globalAccessibilityResults = [];

async function runAccessibilityScan(page, pageName, url, threshold) {
  try {
    await page.waitForLoadState('networkidle');

    const hasValidDOM = await page.evaluate(() => {
      return document && document.documentElement && document.body;
    });

    if (!hasValidDOM) {
      throw new Error(`Invalid DOM structure detected for ${pageName}`);
    }

    await page.waitForTimeout(1000);

    const results = await new AxeBuilder({ page })
      .options({
        runOnly: {
          type: 'tag',
          values: ['wcag2a', 'wcag2aa', 'wcag21aa', 'best-practice']
        }
      })
      .analyze();

    console.log(`Accessibility scan for ${pageName}: ${results.violations.length} violations`);

    globalAccessibilityResults.push({
      page: pageName,
      url,
      results,
    });

    expect(results.violations.length).toBeLessThanOrEqual(threshold);

    return results;
  } catch (error) {
    console.error(`Accessibility scan failed for ${pageName}:`, error.message);

    globalAccessibilityResults.push({
      page: `${pageName} (FAILED)`,
      url,
      results: {
        violations: [],
        incomplete: [],
        passes: [],
        inapplicable: [],
        error: error.message
      },
    });

    throw error;
  }
}

test.describe("Accessibility Tests", () => {
  testConfig.tariffPages.forEach((pageConfig) => {
    test(pageConfig.name, async ({ page }, testInfo) => {
      try {
        await new LoginPage(pageConfig.path, page, testInfo).login();

        await runAccessibilityScan(page, pageConfig.name, pageConfig.path, pageConfig.threshold);
      } catch (error) {
        console.error(`Test failed for ${pageConfig.name}:`, error.message);
        throw error;
      }
    });
  });

  testConfig.adminPages.forEach((pageConfig) => {
    test(pageConfig.name, async ({ page }, testInfo) => {
      try {
        const url = `${process.env.ADMIN_URL}/${pageConfig.path}`;
        await new LoginPage(url, page, testInfo, true).login();

        await runAccessibilityScan(page, pageConfig.name, url, pageConfig.threshold);
      } catch (error) {
        console.error(`Admin test failed for ${pageConfig.name}:`, error.message);
        throw error;
      }
    });
  });

  test.afterAll(async () => {
    console.log(`Total accessibility results collected: ${globalAccessibilityResults.length}`);

    if (globalAccessibilityResults.length === 0) {
      console.warn("No accessibility results were collected. All tests may have failed before scanning.");
      console.warn("Generating empty report to avoid build failure.");

      const emptyResults = [{
        page: "No Results - All Tests Failed",
        url: "N/A",
        results: {
          violations: [],
          incomplete: [],
          passes: [],
          inapplicable: [],
          error: "All accessibility tests failed before scanning could complete"
        }
      }];

      generateHtmlReport(emptyResults, "dist/accessibility-report.html");
      return;
    }

    try {
      generateHtmlReport(globalAccessibilityResults, "dist/accessibility-report.html");
      console.log(`Generated accessibility report with ${globalAccessibilityResults.length} page results`);
    } catch (error) {
      console.error("Failed to generate HTML report:", error);
    }
  });
});
