async function configureWafBypass(
  page,
  serviceUrls = [process.env.BASE_URL, process.env.ADMIN_URL],
  token = process.env.WAF_BYPASS_TOKEN,
) {
  if (!token) return;

  const origins = new Set(serviceUrls.filter(Boolean).map(url => new URL(url).origin));
  await page.route(
    url => origins.has(url.origin),
    route => route.continue({
      headers: { ...route.request().headers(), "x-waf-bypass": token },
    }),
  );
}

module.exports = { configureWafBypass };
