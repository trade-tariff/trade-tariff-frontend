class LoginPage {
  constructor(relativeUrl, page) {
    this.page = page;
    this.url = relativeUrl;
    this.password = process.env.BASIC_PASSWORD;
  }

  async login() {
    const response = await this.page.goto(this.url);
    this.checkResponse(response);

    const loginLocator = this.page.locator("#basic-session-password-field");
    if ((await loginLocator.count()) > 0) {
      await loginLocator.fill(this.password);
      const [destination] = await Promise.all([
        this.page.waitForNavigation({ waitUntil: "domcontentloaded" }),
        this.page.getByRole("button", { name: "Continue" }).click(),
      ]);
      this.checkResponse(destination);
    }
  }

  checkResponse(response) {
    if (!response?.ok()) {
      throw new Error(`Unable to load ${this.url}: HTTP ${response?.status() ?? "unknown"}`);
    }
  }
}

module.exports = { LoginPage };
