const { test, expect } = require("@playwright/test");
const AxeBuilder = require("@axe-core/playwright").default;
const { LoginPage } = require("./pages/loginPage");
const { generateHtmlReport } = require("./utils/generateHtmlReport");
const globalAccessibilityResults = [];

test.describe("Accessibility", () => {
  test("Search for quotas", async ({ page }, testInfo) => {
    await new LoginPage("/quota_search?order_number=052012", page, testInfo).login();
    const results = await new AxeBuilder({ page }).analyze();
    expect(results.violations.length).toBeLessThan(5);

    globalAccessibilityResults.push({ page: "Quota Search", url: "/quota_search?order_number=052012", results });
  });

  test("Find commodity", async ({ page }) => {
    await new LoginPage("/find_commodity", page).login();

    const results = await new AxeBuilder({ page }).analyze();

    expect(results.violations.length).toEqual(3);

    globalAccessibilityResults.push({ page: "Find Commodity", url: "/find_commodity", results });
  });
});

test.afterAll(async () => {
  generateHtmlReport(globalAccessibilityResults, "dist/accessibility-report.html");
});
