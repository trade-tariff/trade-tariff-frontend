const { LoginPage } = require('./accessibility/pages/loginPage');

describe('accessibility page navigation', () => {
  it.each([
    ['https://admin.dev.trade-tariff.service.gov.uk', '/search_references/sections'],
    ['https://admin.dev.trade-tariff.service.gov.uk/', '/search_references/sections'],
    ['https://admin.dev.trade-tariff.service.gov.uk', '/'],
  ])('resolves admin paths against %s without an extra slash', async (baseUrl, path) => {
    const page = {
      goto: jest.fn().mockResolvedValue({ ok: () => true }),
      locator: jest.fn().mockReturnValue({ count: async () => 0 }),
    };

    const loginPage = new LoginPage(path, page, baseUrl);
    await loginPage.login();

    expect(page.goto).toHaveBeenCalledWith(`https://admin.dev.trade-tariff.service.gov.uk${path}`);
    expect(loginPage.url).toBe(`https://admin.dev.trade-tariff.service.gov.uk${path}`);
  });

  it('allows a successful page to be scanned without a login prompt', async () => {
    const page = {
      goto: jest.fn().mockResolvedValue({ ok: () => true }),
      locator: jest.fn().mockReturnValue({ count: async () => 0 }),
    };

    await expect(new LoginPage('/quota_search', page).login()).resolves.toBeUndefined();
  });

  it('rejects a blocked page before it can be scanned', async () => {
    const page = {
      goto: jest.fn().mockResolvedValue({ ok: () => false, status: () => 429 }),
      locator: jest.fn().mockReturnValue({ count: async () => 0 }),
    };

    await expect(new LoginPage('/quota_search', page).login()).rejects.toThrow('HTTP 429');
  });

  it('rejects an unsuccessful navigation after logging in', async () => {
    const page = {
      goto: jest.fn().mockResolvedValue({ ok: () => true }),
      locator: jest.fn().mockReturnValue({ count: async () => 1, fill: async () => {} }),
      getByRole: jest.fn().mockReturnValue({ click: async () => {} }),
      waitForNavigation: jest.fn().mockResolvedValue({ ok: () => false, status: () => 503 }),
    };

    await expect(new LoginPage('/quota_search', page).login()).rejects.toThrow('HTTP 503');
  });

  it('allows a successful destination after logging in', async () => {
    const page = {
      goto: jest.fn().mockResolvedValue({ ok: () => true }),
      locator: jest.fn().mockReturnValue({ count: async () => 1, fill: async () => {} }),
      getByRole: jest.fn().mockReturnValue({ click: async () => {} }),
      waitForNavigation: jest.fn().mockResolvedValue({ ok: () => true }),
    };

    await expect(new LoginPage('/quota_search', page).login()).resolves.toBeUndefined();
  });
});
