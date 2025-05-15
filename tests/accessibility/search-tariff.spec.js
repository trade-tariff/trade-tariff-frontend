const { test, expect } = require("@playwright/test");
const { generateAxeReport } = require("../utils/reportGenerator");
const path = require("path");
const { LoginPage } = require("../pages/loginPage");

test.describe("Find Commodity Page", () => {
  test("Validating the search function with goods name", async ({
    page,
  }, testInfo) => {
    const loginPage = new LoginPage("/find_commodity", page);
    await loginPage.login();

    //await new LoginPage("/find_commodity", page, testInfo).login();
    await page
      .getByRole("combobox", { name: "Search the UK Integrated" })
      .click();
    await page
      .getByRole("combobox", { name: "Search the UK Integrated" })
      .fill("clothes");
    await page
      .getByRole("combobox", { name: "Search the UK Integrated" })
      .press("Enter");

    await expect(
      page.getByRole("heading", { name: "Results matching ‘clothes’" })
    ).toBeVisible();

    // Wait for page navigation to complete
    await page.waitForLoadState("networkidle");

    //  Inject axe-core into the page
    await page.addScriptTag({ path: require.resolve("axe-core") });

    // Inject Axe and run accessibility check
    const results = await page.evaluate(async () => await window.axe.run());

    // Capture screenshot if violations exist
    const screenshotPath = path.join(__dirname, "../reports/screenshot.png");
    await page.screenshot({ path: screenshotPath });

    // Generate the Axe report with the screenshot (if any)
    await generateAxeReport(results, "Commodity-search", screenshotPath);
  });
});
