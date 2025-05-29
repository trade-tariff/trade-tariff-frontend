const { test, expect } = require("@playwright/test");
const { LoginPage } = require("./pages/loginPage");
const AxeBuilder = require("@axe-core/playwright").default;

test.describe("Search for quotas", () => {
  test("Validate UK quota Search Results", async ({ page }, testInfo) => {
    await new LoginPage("/quota_search?order_number=052012", page, testInfo).login();

    const accessibilityScanResults = await new AxeBuilder({ page }).analyze();

    expect(accessibilityScanResults.violations.length).toBeLessThan(5);
  });
});
