// playwright.config.js
require("dotenv").config();

const { defineConfig } = require("@playwright/test");

module.exports = defineConfig({
  use: {
    baseURL:
      process.env.BASE_URL || "https://staging.trade-tariff.service.gov.uk",
    // other global config if needed
  },
});
