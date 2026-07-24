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

  it('records submit-to-visible timing once the destination page connects', async () => {
    application = Application.start();
    application.register('guided-search-page', GuidedSearchPageController);
    await Promise.resolve();

    expect(window.fetch).toHaveBeenCalledWith(
      '/search/guided-search-event',
      expect.objectContaining({
        method: 'POST',
        keepalive: true,
        body: JSON.stringify({
          event_type: 'page_visible',
          request_id: 'request-123',
          destination: 'question',
          client_navigation_ms: 1234,
        }),
      }),
    );
    expect(window.sessionStorage.getItem('guidedSearchSubmittedAt')).toBeNull();
  });
});
