class LoginPage {
  constructor(relativeUrl, page) {
    this.page = page;
    this.url = relativeUrl; // just relative URL, e.g. "/find_commodity"
    this.password = process.env.BASIC_PASSWORD || "tariff123";
  }

  async login() {
    await this.page.goto(this.url); // Playwright prepends baseURL automatically
    console.log("Navigating to:", process.env.BASE_URL + this.url);

    const loginLocator = this.page.locator("#basic-session-password-field");
    if ((await loginLocator.count()) > 0) {
      await loginLocator.fill(this.password);
      await this.page.getByRole("button", { name: "Continue" }).click();
    }
  }
}

module.exports = { LoginPage };
