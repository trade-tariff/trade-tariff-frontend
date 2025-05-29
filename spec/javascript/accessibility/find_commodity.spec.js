const { test, expect } = require("@playwright/test");
const { LoginPage } = require("./pages/loginPage");
const AxeBuilder = require("@axe-core/playwright").default;

test.describe("Find Commodity Page", () => {
  test("Validating accessibility", async ({ page }) => {
    await new LoginPage("/", page).login();

    const accessibilityScanResults = await new AxeBuilder({ page }).analyze();

    expect(accessibilityScanResults.violations.length).toEqual(3);
  });
});
