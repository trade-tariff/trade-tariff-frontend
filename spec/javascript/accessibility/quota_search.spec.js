const { test, expect } = require("@playwright/test");
const { LoginPage } = require("./pages/loginPage");
const AxeBuilder = require("@axe-core/playwright").default;

test.describe("Search for quotas", () => {
  test("Validate UK quota Search Results", async ({ page }, testInfo) => {
    await new LoginPage("/quota_search", page, testInfo).login();

    await expect(
      page.getByRole("heading", { name: "Search for quotas" })
    ).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter the 6-digit quota order" })
      .fill("052016");

    //Select a country to which the quota applies
    await page
      .getByRole("combobox", { name: "Select a country to which the" })
      .click();
    await page.getByRole("option", { name: "Albania (AL)" }).click();

    //search for quotas
    await page.getByRole("button", { name: "Search for quotas" }).click();

    //Validation
    await expect(
      page.getByRole("heading", { name: "Quota search results" })
    ).toBeVisible();
    await expect(
      page.getByRole("columnheader", { name: "Order number" })
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Opens in a popup" })
    ).toHaveText("052016");

    const accessibilityScanResults = await new AxeBuilder({ page }).analyze();

    expect(accessibilityScanResults.violations.length).toBeLessThan(5);
  });
});
