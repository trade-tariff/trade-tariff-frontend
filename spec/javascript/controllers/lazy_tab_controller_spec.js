import {Application} from '@hotwired/stimulus';
import LazyTabController from '../../../app/javascript/controllers/lazy_tab_controller';

describe('LazyTabController', () => {
  let application;
  let element;

  beforeEach(async () => {
    document.body.innerHTML = `
      <div class="govuk-tabs">
        <ul class="govuk-tabs__list">
          <li class="govuk-tabs__list-item">
            <a class="govuk-tabs__tab" href="#rules-of-origin">Origin</a>
          </li>
        </ul>
        <div class="govuk-tabs__panel" id="rules-of-origin">
          <div data-controller="lazy-tab"
               data-lazy-tab-url-value="/commodities/0101300000/origin">
            <p>Loading&hellip;</p>
          </div>
        </div>
      </div>
    `;

    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        text: () => Promise.resolve('<p class="origin-content">Origin content</p>'),
      })
    );

    application = Application.start();
    application.register('lazy-tab', LazyTabController);
    element = document.querySelector('[data-controller="lazy-tab"]');

    await new Promise((resolve) => setTimeout(resolve, 0));
  });

  afterEach(() => {
    application.stop();
    jest.clearAllMocks();
    window.location.hash = '';
  });

  it('does not fetch on connect when hash does not match', () => {
    expect(global.fetch).not.toHaveBeenCalled();
  });

  it('fetches and injects content when the tab link is clicked', async () => {
    const tabLink = document.querySelector('a[href="#rules-of-origin"]');
    tabLink.click();

    await new Promise((resolve) => setTimeout(resolve, 50));

    expect(global.fetch).toHaveBeenCalledWith(
      '/commodities/0101300000/origin',
      expect.objectContaining({headers: expect.any(Object)})
    );
    expect(element.innerHTML).toContain('origin-content');
  });

  it('does not fetch a second time when the tab is clicked again', async () => {
    const tabLink = document.querySelector('a[href="#rules-of-origin"]');
    tabLink.click();
    await new Promise((resolve) => setTimeout(resolve, 50));

    tabLink.click();
    await new Promise((resolve) => setTimeout(resolve, 50));

    expect(global.fetch).toHaveBeenCalledTimes(1);
  });

  it('shows a GOV.UK error message when the server returns a non-2xx response', async () => {
    global.fetch = jest.fn(() =>
      Promise.resolve({ok: false, status: 500})
    );

    const tabLink = document.querySelector('a[href="#rules-of-origin"]');
    tabLink.click();

    await new Promise((resolve) => setTimeout(resolve, 50));

    expect(element.innerHTML).toContain('govuk-error-message');
    expect(element.innerHTML).toContain('could not be loaded');
  });

  it('shows a GOV.UK error message on a network failure', async () => {
    global.fetch = jest.fn(() => Promise.reject(new Error('Network error')));

    const tabLink = document.querySelector('a[href="#rules-of-origin"]');
    tabLink.click();

    await new Promise((resolve) => setTimeout(resolve, 50));

    expect(element.innerHTML).toContain('govuk-error-message');
    expect(element.innerHTML).toContain('could not be loaded');
  });
});
