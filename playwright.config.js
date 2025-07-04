import { defineConfig, devices } from "@playwright/test";
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
  use: { trace: "off", baseURL: baseURL },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
    },
  ],
  timeout: 140000,
});
