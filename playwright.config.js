import { defineConfig, devices } from "@playwright/test";
import { wafBypassHeaders } from "./spec/javascript/accessibility/utils/wafBypassHeaders";
require('dotenv').config();

const baseURL = process.env.BASE_URL;
const onCI = (process.env.CI ?? "false") === "true";

// See https://playwright.dev/docs/test-configuration.
export default defineConfig({
  testDir: "./spec/javascript/accessibility/",
  fullyParallel: true,
  forbidOnly: onCI,
  retries: onCI ? 1 : 0,
  workers: onCI ? 1 : 1,
  reporter: "html",
  use: { trace: "off", baseURL: baseURL, extraHTTPHeaders: wafBypassHeaders() },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
  timeout: 140000,
});
