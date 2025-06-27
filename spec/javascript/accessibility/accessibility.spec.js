const { test, expect } = require("@playwright/test");
const AxeBuilder = require("@axe-core/playwright").default;
const { LoginPage } = require("./pages/loginPage");
const { generateHtmlReport } = require("./utils/generateHtmlReport");
const globalAccessibilityResults = [];

test.describe("Accessibility", () => {
  test("Search for quotas", async ({ page }, testInfo) => {
    await new LoginPage(
      "/quota_search?order_number=052012",
      page,
      testInfo
    ).login();
    const results = await new AxeBuilder({ page }).analyze();
    expect(results.violations.length).toBeLessThan(5);

    globalAccessibilityResults.push({
      page: "Quota Search",
      url: "/quota_search?order_number=052012",
      results,
    });
  });

  test("Find commodity", async ({ page }) => {
    await new LoginPage("/find_commodity", page).login();

    const results = await new AxeBuilder({ page }).analyze();

    expect(results.violations.length).toBeLessThan(5);

    globalAccessibilityResults.push({
      page: "Find Commodity",
      url: "/find_commodity",
      results,
    });
  });

  test("Validating browsing the tariff", async ({ page }, testInfo) => {
    await new LoginPage("/browse", page, testInfo).login();

    const results = await new AxeBuilder({ page }).analyze();

    expect(results.violations.length).toBeLessThan(5);

    globalAccessibilityResults.push({
      page: "browsing the tariff",
      url: "/browse",
      results,
    });
  });

  test("Validating a-z navigation of the tariff", async ({
    page,
  }, testInfo) => {
    await new LoginPage("/a-z-index/a", page, testInfo).login();

    const results = await new AxeBuilder({ page }).analyze();

    expect(results.violations.length).toBeLessThan(5);

    globalAccessibilityResults.push({
      page: "a-z navigation of the tariff",
      url: "/a-z-index/a",
      results,
    });
  });

  test("Verify Rules of Origin are displayed for selected commodity", async ({
    page,
  }, testInfo) => {
    await new LoginPage("/commodities/0409000010", page, testInfo).login();

    const results = await new AxeBuilder({ page }).analyze();

    expect(results.violations.length).toBeLessThan(9);

    globalAccessibilityResults.push({
      page: "displayed for selected commodity",
      url: "/commodities/0409000010",
      results,
    });
  });

  test("Validating the duty calculator", async ({ page }, testInfo) => {
    await new LoginPage("/commodities/0702001007", page, testInfo).login();

    const results = await new AxeBuilder({ page }).analyze();

    expect(results.violations.length).toBeLessThan(9);

    globalAccessibilityResults.push({
      page: "validating the duty calculator",
      url: "/commodities/0702001007",
      results,
    });
  });

  test("Validating exchange rates", async ({ page }, testInfo) => {
    await new LoginPage("/exchange_rates", page, testInfo).login();

    const results = await new AxeBuilder({ page }).analyze();

    expect(results.violations.length).toBeLessThan(9);

    globalAccessibilityResults.push({
      page: "Validating exchange rates",
      url: "/exchange_rates",
      results,
    });
  });

  // Admin
  test("Notes", async ({ page }, testInfo) => {
    // Step 1: Login
    await new LoginPage(process.env.ADMIN_URL, page, testInfo, true).login();
    await page.waitForLoadState("networkidle");

    // Step 2: Navigate to the page
    await page.getByRole("link", { name: "Section & chapter notes" }).click();
    await page.getByRole("link", { name: "to 5" }).click();
    await expect(
      page.getByRole("cell", { name: "Live Animals" })
    ).toBeVisible();

    // Step 3: Run axe accessibility scan
    const results = await new AxeBuilder({ page }).analyze();

    // Step 4: Optional threshold (tweak as needed)
    expect(results.violations.length).toBeLessThan(9);

    // Step 5: Store results
    globalAccessibilityResults.push({
      page: "Notes",
      url: "${process.env.ADMIN_URL}/admin-notes",
      results,
    });
  });

  test("Search References", async ({ page }, testInfo) => {
    // Step 1: Login
    await new LoginPage(process.env.ADMIN_URL, page, testInfo, true).login();

    // Step 2: Navigate to the page
    await page.getByRole("link", { name: "Search references" }).click();
    await page.getByRole("link", { name: "1 to 5" }).click();
    await page.getByRole("link", { name: "0101 to 0106" }).click();
    await page.getByRole("link", { name: "Commodities in 0101" }).click();

    await expect(
      page.getByRole("heading", {
        name: "Commodities search references of heading 0101:Live Horses, Asses, Mules And Hinnies",
      })
    ).toBeVisible();

    // Step 3: Run axe accessibility scan
    const results = await new AxeBuilder({ page }).analyze();

    // Step 4: Optional threshold (tweak as needed)
    expect(results.violations.length).toBeLessThan(9);

    // Step 5: Store results
    globalAccessibilityResults.push({
      page: "search References",
      url: "${process.env.ADMIN_URL}/search_references/sections",
      results,
    });
  });

  test("tariff_updates", async ({ page }, testInfo) => {
    // Step 1: Login
    await new LoginPage(process.env.ADMIN_URL, page, testInfo, true).login();

    // Step 2: Navigate to the page
    await page.getByRole("listitem").filter({ hasText: "Updates" }).click();
    await expect(
      page.getByRole("heading", { name: "Tariff Updates - CDS" })
    ).toBeVisible();

    // Step 3: Run axe accessibility scan
    const results = await new AxeBuilder({ page }).analyze();

    // Step 4: Optional threshold (tweak as needed)
    expect(results.violations.length).toBeLessThan(9);

    // Step 5: Store results
    globalAccessibilityResults.push({
      page: "tariff_updates",
      url: "${process.env.ADMIN_URL}/tariff_updates",
      results,
    });
  });
});

test.afterAll(async () => {
  generateHtmlReport(
    globalAccessibilityResults,
    "dist/accessibility-report.html"
  );
});
