const fs = require("fs");
const path = require("path");
const { test, expect } = require("@playwright/test");
const AxeBuilder = require("@axe-core/playwright").default;
const { LoginPage } = require("./pages/loginPage");
const { execSync } = require("child_process");

test("Accessibility check", async ({ page }, testInfo) => {
  await new LoginPage(
    "/quota_search?order_number=052012",
    page,
    testInfo
  ).login();

  const results = await new AxeBuilder({ page }).analyze();
  expect(results.violations.length).toBeLessThan(5);

  // Save JSON
  const jsonOutputPath = "./axe-reports/report-latest.json";
  fs.mkdirSync(path.dirname(jsonOutputPath), { recursive: true });
  fs.writeFileSync(jsonOutputPath, JSON.stringify(results, null, 2));
  console.log(`✅ Accessibility JSON report saved at: ${jsonOutputPath}`);

  // Run report generator with correct relative path
  const generatorPath = path.resolve(
    __dirname,
    "./utils/generate-html-report.js"
  );

  try {
    execSync(`node "${generatorPath}"`, { stdio: "inherit" });
  } catch (err) {
    console.error("Failed to generate HTML report:", err.message);
    throw err;
  }
});
