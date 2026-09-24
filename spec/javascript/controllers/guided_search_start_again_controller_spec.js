import {Application} from '@hotwired/stimulus';
import Cookies from 'js-cookie';
import GuidedSearchStartAgainController from '../../../app/javascript/controllers/guided_search_start_again_controller';

describe('GuidedSearchStartAgainController', () => {
  let application;

  beforeEach(() => {
    document.head.innerHTML = `
      <meta name="csrf-token" content="csrf-token-123">
      <script type="application/json" id="search-analytics-context">${JSON.stringify({
        search_experience: 'guided_beta',
        search_mode: 'guided',
        search_state: 'results',
        request_id: 'request-123',
      })}</script>
    `;
    document.body.innerHTML = `
      <a href="/find_commodity"
         data-controller="guided-search-start-again"
         data-action="click->guided-search-start-again#select"
         data-guided-search-start-again-event-url-value="/search/guided-search-event"
         data-guided-search-start-again-request-id-value="request-123"
         data-guided-search-start-again-destination-value="results">
        Start search again
      </a>
    `;
    Cookies.set('cookies_policy', JSON.stringify({usage: true}));
    window.dataLayer = [];
    window.fetch = jest.fn().mockResolvedValue({ok: true});
    window.sessionStorage.setItem('guidedSearchPageVisibleAt', '1000');
    jest.spyOn(Date, 'now').mockReturnValue(4100);

    application = Application.start();
    application.register('guided-search-start-again', GuidedSearchStartAgainController);
  });

  afterEach(() => {
    application.stop();
    Cookies.remove('cookies_policy');
    window.sessionStorage.clear();
    delete window.dataLayer;
    delete window.fetch;
    jest.restoreAllMocks();
  });

  it('records start again and wait time without preventing navigation', () => {
    const link = document.querySelector('a');
    const event = new MouseEvent('click', {bubbles: true, cancelable: true});

    link.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(false);
    expect(window.dataLayer).toEqual([expect.objectContaining({
      event: 'ott_search_journey',
      outcome: 'start_again',
      destination: 'results',
      client_elapsed_ms: 3100,
    })]);
    expect(window.fetch).toHaveBeenCalledWith(
      '/search/guided-search-event',
      expect.objectContaining({
        method: 'POST',
        keepalive: true,
        body: JSON.stringify({
          event_type: 'start_again',
          request_id: 'request-123',
          destination: 'results',
          client_elapsed_ms: 3100,
        }),
      }),
    );
  });

  it('records the server event when usage consent is absent', () => {
    Cookies.remove('cookies_policy');
    window.dataLayer = [];

    document.querySelector('a').dispatchEvent(new MouseEvent('click', {bubbles: true, cancelable: true}));

    expect(window.dataLayer).toEqual([]);
    expect(JSON.parse(window.fetch.mock.calls.at(-1)[1].body)).toMatchObject({
      event_type: 'start_again',
      destination: 'results',
      client_elapsed_ms: 3100,
    });
  });
});
