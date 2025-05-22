class LoginPage {
  constructor(relativeUrl, page) {
    this.page = page;
    this.url = relativeUrl;
    this.password = process.env.BASIC_PASSWORD
  }

  async login() {
    await this.page.goto(this.url);

    const loginLocator = this.page.locator("#basic-session-password-field");
    if ((await loginLocator.count()) > 0) {
      await loginLocator.fill(this.password);
      await this.page.getByRole("button", { name: "Continue" }).click();
    }
  }
}

module.exports = { LoginPage };
