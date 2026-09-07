const { configureWafBypass } = require('./accessibility/utils/configureWafBypass');

describe('accessibility WAF bypass', () => {
  afterEach(() => jest.restoreAllMocks());

  it('adds the token only to requests for the configured service origins', async () => {
    const page = { route: jest.fn() };
    await configureWafBypass(page, ['https://dev.example.test', 'https://admin.dev.example.test'], 'test-token');

    const [matches, handle] = page.route.mock.calls[0];
    expect(matches(new URL('https://dev.example.test/quota_search'))).toBe(true);
    expect(matches(new URL('https://admin.dev.example.test/assets/app.js'))).toBe(true);
    expect(matches(new URL('https://www.googletagmanager.com/gtm.js'))).toBe(false);
    expect(matches(new URL('https://dev.example.test.other.test/'))).toBe(false);
    expect(matches(new URL('http://dev.example.test/'))).toBe(false);

    const route = {
      request: () => ({ headers: () => ({ accept: 'text/html' }) }),
      continue: jest.fn(),
    };
    await handle(route);
    expect(route.continue).toHaveBeenCalledWith({
      headers: { accept: 'text/html', 'x-waf-bypass': 'test-token' },
    });
  });

  it('does not intercept requests without a token', async () => {
    const page = { route: jest.fn() };
    await configureWafBypass(page, ['https://dev.example.test'], '');

    expect(page.route).not.toHaveBeenCalled();
  });

  it('reads service origins and the token from the workflow environment', async () => {
    jest.replaceProperty(process, 'env', {
      ...process.env,
      BASE_URL: 'https://dev.example.test',
      ADMIN_URL: 'https://admin.dev.example.test',
      WAF_BYPASS_TOKEN: 'ci-token',
    });
    const page = { route: jest.fn() };
    await configureWafBypass(page);

    const [matches, handle] = page.route.mock.calls[0];
    expect(matches(new URL(process.env.BASE_URL))).toBe(true);
    expect(matches(new URL(process.env.ADMIN_URL))).toBe(true);
    const route = { request: () => ({ headers: () => ({}) }), continue: jest.fn() };
    await handle(route);
    expect(route.continue).toHaveBeenCalledWith({ headers: { 'x-waf-bypass': 'ci-token' } });
  });

  it('ignores an unconfigured optional service URL', async () => {
    const page = { route: jest.fn() };
    await configureWafBypass(page, ['https://dev.example.test', undefined], 'test-token');

    const [matches] = page.route.mock.calls[0];
    expect(matches(new URL('https://dev.example.test/'))).toBe(true);
    expect(matches(new URL('https://admin.dev.example.test/'))).toBe(false);
  });
});
