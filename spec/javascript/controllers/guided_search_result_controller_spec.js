import {Application} from '@hotwired/stimulus';
import GuidedSearchResultController from '../../../app/javascript/controllers/guided_search_result_controller';

describe('GuidedSearchResultController', () => {
  let application;

  beforeEach(() => {
    document.head.innerHTML = '<meta name="csrf-token" content="csrf-token-123">';
    document.body.innerHTML = `
      <a href="/commodities/2007919930?request_id=request-123"
         data-controller="guided-search-result"
         data-action="click->guided-search-result#select"
         data-guided-search-result-event-url-value="/search/guided-search-event"
         data-guided-search-result-request-id-value="request-123"
         data-guided-search-result-goods-nomenclature-item-id-value="2007919930"
         data-guided-search-result-rank-value="2"
         data-guided-search-result-confidence-value="good">
        View this commodity code
      </a>
    `;
    window.fetch = jest.fn().mockResolvedValue({ok: true});

    application = Application.start();
    application.register('guided-search-result', GuidedSearchResultController);
  });

  afterEach(() => {
    application.stop();
    delete window.fetch;
  });

  it('records rank and confidence without preventing navigation', () => {
    const link = document.querySelector('a');
    const event = new MouseEvent('click', {bubbles: true, cancelable: true});

    link.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(false);
    expect(window.fetch).toHaveBeenCalledWith(
      '/search/guided-search-event',
      expect.objectContaining({
        method: 'POST',
        keepalive: true,
        body: JSON.stringify({
          event_type: 'result_selected',
          request_id: 'request-123',
          goods_nomenclature_item_id: '2007919930',
          result_rank: 2,
          confidence: 'good',
        }),
      }),
    );
  });
});
