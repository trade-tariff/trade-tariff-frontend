const { wafBypassHeaders } = require('./accessibility/utils/wafBypassHeaders');

describe('accessibility WAF bypass headers', () => {
  afterEach(() => jest.restoreAllMocks());

  it('uses the configured token as a request header', () => {
    expect(wafBypassHeaders('test-token')).toEqual({ 'x-waf-bypass': 'test-token' });
  });

  it('does not send a bypass header when no token is configured', () => {
    expect(wafBypassHeaders('')).toEqual({});
  });

  it('reads the token supplied by the workflow environment', () => {
    jest.replaceProperty(process, 'env', { ...process.env, WAF_BYPASS_TOKEN: 'ci-token' });

    expect(wafBypassHeaders()).toEqual({ 'x-waf-bypass': 'ci-token' });
  });

  it('allows local runs without the workflow environment', () => {
    const environment = { ...process.env };
    delete environment.WAF_BYPASS_TOKEN;
    jest.replaceProperty(process, 'env', environment);

    expect(wafBypassHeaders()).toEqual({});
  });
});
