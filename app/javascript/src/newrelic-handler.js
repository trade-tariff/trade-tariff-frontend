/**
 * Configure New Relic error handler to suppress expected GTM CSP violations
 * HMRC-2183: Filter out non-actionable errors from Google Tag Manager
 */
const GTM_IDENTIFIER = 'googletagmanager';
const CSP_MESSAGE_FRAGMENT = 'Content Security Policy';

export function initializeNewRelicErrorHandler() {
  const nr = window.newrelic;

  if (!nr || typeof nr.setErrorHandler !== 'function') {
    return;
  }

  nr.setErrorHandler((err) => {
    if (!err) return false;

    const message = err.message ?? '';
    const stack = err.stack ?? '';

    const isGTMCspViolation =
      message.includes(CSP_MESSAGE_FRAGMENT) &&
      stack.includes(GTM_IDENTIFIER);

    return isGTMCspViolation;
  });
}

if (document.readyState !== 'loading') {
  initializeNewRelicErrorHandler();
} else {
  document.addEventListener('DOMContentLoaded', initializeNewRelicErrorHandler, { once: true });
}
