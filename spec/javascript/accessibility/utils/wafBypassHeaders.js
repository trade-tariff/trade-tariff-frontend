function wafBypassHeaders(token = process.env.WAF_BYPASS_TOKEN) {
  return token ? { "x-waf-bypass": token } : {};
}

module.exports = { wafBypassHeaders };
