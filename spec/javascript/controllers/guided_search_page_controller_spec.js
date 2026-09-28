import {Application} from '@hotwired/stimulus';
import GuidedSearchPageController from '../../../app/javascript/controllers/guided_search_page_controller';

describe('GuidedSearchPageController', () => {
  let application;

  beforeEach(() => {
    document.head.innerHTML = '<meta name="csrf-token" content="csrf-token-123">';
    document.body.innerHTML = `
      <div data-controller="guided-search-page"
           data-guided-search-page-event-url-value="/search/guided-search-event"
           data-guided-search-page-request-id-value="request-123"
           data-guided-search-page-outcome-value="question"></div>
    `;
    window.fetch = jest.fn().mockResolvedValue({ok: true});
    window.sessionStorage.setItem('guidedSearchSubmittedAt', '3766');
    jest.spyOn(Date, 'now').mockReturnValue(5000);
  });

  afterEach(() => {
    if (application) application.stop();
    window.sessionStorage.clear();
    delete window.fetch;
    jest.restoreAllMocks();
  });

  it.each([null, '', 'invalid', '0'])('records visibility without a usable navigation timer (%s)', async (timer) => {
    if (timer === null) {
      window.sessionStorage.removeItem('guidedSearchSubmittedAt');
    } else {
      window.sessionStorage.setItem('guidedSearchSubmittedAt', timer);
    }
    application = Application.start();
    application.register('guided-search-page', GuidedSearchPageController);
    await Promise.resolve();

    expect(window.fetch).toHaveBeenCalledTimes(1);
    const body = JSON.parse(window.fetch.mock.calls[0][1].body);
    expect(body).toMatchObject({
      event_type: 'page_visible',
      request_id: 'request-123',
      destination: 'question',
    });
    expect(body.client_navigation_ms).toBeUndefined();
    expect(body.event_id).toMatch(/^[a-zA-Z0-9-]{1,64}$/);
    expect(window.sessionStorage.getItem('guidedSearchSubmittedAt')).toBeNull();
  });

  it('does not post without an event endpoint', async () => {
    document.querySelector('[data-controller]').removeAttribute('data-guided-search-page-event-url-value');
    application = Application.start();
    application.register('guided-search-page', GuidedSearchPageController);
    await Promise.resolve();

    expect(window.fetch).not.toHaveBeenCalled();
  });

  it('links the visible question to the server-provided question identity without storage', async () => {
    const page = document.querySelector('[data-controller]');
    page.setAttribute('data-guided-search-page-request-id-value', 'request-123');
    page.setAttribute('data-guided-search-page-question-id-value', 'question-123');
    jest.spyOn(Storage.prototype, 'getItem').mockImplementation(() => { throw new Error('blocked'); });
    jest.spyOn(Storage.prototype, 'setItem').mockImplementation(() => { throw new Error('blocked'); });
    application = Application.start();
    application.register('guided-search-page', GuidedSearchPageController);
    await Promise.resolve();

    expect(JSON.parse(window.fetch.mock.calls[0][1].body)).toMatchObject({
      event_type: 'page_visible', destination: 'question',
      request_id: 'request-123', question_id: 'question-123',
    });
    expect(JSON.parse(window.fetch.mock.calls[0][1].body)).not.toHaveProperty('journey_id');
  });

  it('records a fresh visible outcome when the browser restores the cached page', async () => {
    const page = document.querySelector('[data-controller]');
    page.setAttribute('data-guided-search-page-request-id-value', 'request-123');
    application = Application.start();
    application.register('guided-search-page', GuidedSearchPageController);
    await Promise.resolve();
    const first = JSON.parse(window.fetch.mock.calls[0][1].body);

    window.dispatchEvent(new PageTransitionEvent('pageshow', { persisted: true }));
    const restored = JSON.parse(window.fetch.mock.calls[1][1].body);
    expect(restored.request_id).toBe(first.request_id);
    expect(restored.event_id).not.toBe(first.event_id);
    expect(restored.destination).toBe('question');
    expect(restored).not.toHaveProperty('client_navigation_ms');

    const calls = window.fetch.mock.calls.length;
    window.dispatchEvent(new PageTransitionEvent('pageshow', { persisted: false }));
    expect(window.fetch).toHaveBeenCalledTimes(calls);
  });

  it('does not attach an unrelated stored journey to a page with no journey identity', async () => {
    window.sessionStorage.setItem('guidedSearchJourney', JSON.stringify({ journeyId: 'previous-journey' }));
    application = Application.start();
    application.register('guided-search-page', GuidedSearchPageController);
    await Promise.resolve();

    expect(JSON.parse(window.fetch.mock.calls[0][1].body)).not.toHaveProperty('journey_id');
  });

  it('records submit-to-visible timing once the destination page connects', async () => {
    application = Application.start();
    application.register('guided-search-page', GuidedSearchPageController);
    await Promise.resolve();

    expect(window.fetch).toHaveBeenCalledWith(
      '/search/guided-search-event',
      expect.objectContaining({
        method: 'POST',
        keepalive: true,
        body: expect.any(String),
      }),
    );
    expect(JSON.parse(window.fetch.mock.calls[0][1].body)).toMatchObject({
      event_type: 'page_visible',
      request_id: 'request-123',
      destination: 'question',
      client_navigation_ms: 1234,
    });
    expect(window.sessionStorage.getItem('guidedSearchSubmittedAt')).toBeNull();
  });
});
