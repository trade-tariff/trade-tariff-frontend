import { Application } from '@hotwired/stimulus';
import CommoditySearchController from '../../../app/javascript/controllers/commodity_search_controller';
import CookieManager from '../../../app/javascript/src/cookie-manager';
import Cookies from 'js-cookie';
import accessibleAutocomplete from 'accessible-autocomplete';
import { initializeSearchAutocomplete } from '../../../app/javascript/src/search-autocomplete';

describe('CommoditySearchController', () => {
  let application;
  const cookieManager = new CookieManager();

  function resetCookies() {
    Object.keys(Cookies.get()).forEach((cookieName) => Cookies.remove(cookieName));
  }

  // Mirrors the markup contract: the wrapper carries the window keydown
  // action, the trigger is a real link so it still works without JavaScript,
  // and the panel starts hidden. The search-mode controller enables only the
  // inputs of the active section, so the keyword input starts enabled and the
  // guided textarea disabled.
  const PANEL_KEYWORD_ONLY = `
    <div data-controller="commodity-search"
         data-action="keydown@window->commodity-search#keydown">
      <a href="/search" id="commodity-search-toggle"
         data-commodity-search-target="trigger"
         data-action="click->commodity-search#toggle">Search for a commodity</a>
      <div id="commodity-search-panel" data-commodity-search-target="panel" hidden>
        <form id="new_search">
          <input type="hidden" name="resource_id" id="resource_id" value="123">
          <input type="text" name="q" id="revised-keyword-query" value="">
          <textarea name="q" id="guided-query" disabled></textarea>
          <button type="button" data-action="commodity-search#close">Close</button>
        </form>
      </div>
    </div>
  `;

  async function render(markup = PANEL_KEYWORD_ONLY) {
    document.body.innerHTML = markup;

    application = Application.start();
    application.register('commodity-search', CommoditySearchController);
    await new Promise((resolve) => setTimeout(resolve, 0));
    return document.querySelector('[data-controller="commodity-search"]');
  }

  function trigger() {
    return document.getElementById('commodity-search-toggle');
  }

  function panel() {
    return document.getElementById('commodity-search-panel');
  }

  function clickTrigger() {
    trigger().dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));
  }

  function windowKeydown(key, options = {}) {
    const target = options.target || document.body;
    const event = new KeyboardEvent('keydown', {
      key,
      bubbles: true,
      cancelable: true,
      ...options,
    });
    target.dispatchEvent(event);
    return event;
  }

  beforeEach(() => {
    resetCookies();
  });

  afterEach(() => {
    application?.stop();
    document.body.innerHTML = '';
    resetCookies();
  });

  describe('connect', () => {
    it('starts collapsed and marks the trigger as a disclosure button', async () => {
      await render();

      expect(panel().hidden).toBe(true);
      expect(trigger().getAttribute('role')).toEqual('button');
      expect(trigger().getAttribute('aria-expanded')).toEqual('false');
      expect(trigger().getAttribute('aria-controls')).toEqual('commodity-search-panel');
    });

    it('stores nothing when the user has not allowed settings cookies', async () => {
      await render();
      clickTrigger();

      expect(panel().hidden).toBe(false);
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();
    });

    it('does not restore or save a choice when settings consent is malformed', async () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: 1});
      cookieManager.setCommoditySearchOpen('open');

      await render();

      expect(panel().hidden).toBe(true);
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();
    });

    it('does not restore a stored choice after the user withdraws settings cookies', async () => {
      cookieManager.setCommoditySearchOpen('open');
      cookieManager.setCookiesPolicy({usage: false, remember_settings: false});

      await render();

      expect(panel().hidden).toBe(true);
      expect(cookieManager.getCommoditySearchOpen()).toBeNull();
    });

    it('restores an open choice without stealing focus or renewing the cookie', async () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
      cookieManager.setCommoditySearchOpen('open');
      const setCookie = jest.spyOn(Cookies, 'set');
      document.body.innerHTML = `
        <button id="elsewhere">Elsewhere</button>
        ${PANEL_KEYWORD_ONLY}
      `;
      document.getElementById('elsewhere').focus();

      application = Application.start();
      application.register('commodity-search', CommoditySearchController);
      await new Promise((resolve) => setTimeout(resolve, 0));

      expect(panel().hidden).toBe(false);
      expect(trigger().getAttribute('aria-expanded')).toEqual('true');
      expect(document.activeElement).toEqual(document.getElementById('elsewhere'));
      expect(setCookie).not.toHaveBeenCalled();
      expect(cookieManager.getCommoditySearchOpen()).toEqual('open');
    });

    it('restores a closed choice', async () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
      cookieManager.setCommoditySearchOpen('closed');

      await render();

      expect(panel().hidden).toBe(true);
      expect(trigger().getAttribute('aria-expanded')).toEqual('false');
    });

    it('leaves the hierarchy cookie alone', async () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
      cookieManager.setCommodityHierarchyOpen('open');

      await render();
      clickTrigger(); // opens, remembers open

      expect(cookieManager.getCommodityHierarchyOpen()).toEqual('open');
      expect(cookieManager.getCommoditySearchOpen()).toEqual('open');
    });
  });

  describe('toggle', () => {
    beforeEach(() => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
    });

    it('opens the panel, focuses the active search input and remembers open', async () => {
      await render();

      clickTrigger();

      expect(panel().hidden).toBe(false);
      expect(trigger().getAttribute('aria-expanded')).toEqual('true');
      expect(document.activeElement).toEqual(document.getElementById('revised-keyword-query'));
      expect(cookieManager.getCommoditySearchOpen()).toEqual('open');
    });

    it('does not focus the hidden resource_id input or a disabled input', async () => {
      await render();
      document.getElementById('revised-keyword-query').disabled = true;
      document.getElementById('guided-query').disabled = false;

      clickTrigger();

      expect(document.activeElement).toEqual(document.getElementById('guided-query'));
    });

    it('does not focus an input inside a hidden section', async () => {
      await render();
      const guidedSection = document.createElement('div');
      guidedSection.hidden = true;
      const guidedInput = document.createElement('input');
      guidedInput.type = 'text';
      guidedSection.appendChild(guidedInput);
      panel().querySelector('form').appendChild(guidedSection);

      clickTrigger();

      expect(document.activeElement).toEqual(document.getElementById('revised-keyword-query'));
    });

    it('closes an open panel, returns focus to the trigger and remembers closed', async () => {
      await render();
      clickTrigger();

      clickTrigger();

      expect(panel().hidden).toBe(true);
      expect(trigger().getAttribute('aria-expanded')).toEqual('false');
      expect(document.activeElement).toEqual(trigger());
      expect(cookieManager.getCommoditySearchOpen()).toEqual('closed');
    });

    it('prevents the link navigation only when JavaScript handles the click', async () => {
      await render();

      const event = new MouseEvent('click', { bubbles: true, cancelable: true });
      trigger().dispatchEvent(event);

      expect(event.defaultPrevented).toBe(true);
    });
  });

  describe('close', () => {
    beforeEach(() => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
    });

    it('hides an open panel and returns focus to the trigger', async () => {
      await render();
      clickTrigger();

      document.querySelector('[data-action="commodity-search#close"]')
          .dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));

      expect(panel().hidden).toBe(true);
      expect(trigger().getAttribute('aria-expanded')).toEqual('false');
      expect(document.activeElement).toEqual(trigger());
      expect(cookieManager.getCommoditySearchOpen()).toEqual('closed');
    });

    it('does nothing when the panel is already closed', async () => {
      await render();
      document.body.focus();

      document.querySelector('[data-action="commodity-search#close"]')
          .dispatchEvent(new MouseEvent('click', { bubbles: true, cancelable: true }));

      expect(panel().hidden).toBe(true);
      expect(document.activeElement).not.toEqual(trigger());
    });
  });

  describe('with the real autocomplete', () => {
    let populateSuggestions;
    const flushUpdates = () => new Promise((resolve) => setTimeout(resolve, 0));

    beforeEach(async () => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
      await render(PANEL_KEYWORD_ONLY.replace(
        '<input type="text" name="q" id="revised-keyword-query" value="">',
        '<div id="autocomplete" data-input-id="revised-keyword-query" data-input-name="q"></div>',
      ) + '<div class="path_info" data-search-suggestions-path="/search_suggestions.json"></div>');
      initializeSearchAutocomplete(document.getElementById('autocomplete'), {
        accessibleAutocomplete,
        debounce: (callback) => callback,
        fetchSuggestions: (_query, _path, _options, populate) => { populateSuggestions = populate; },
      });
      clickTrigger();
    });

    async function typeQuery() {
      const input = document.getElementById('revised-keyword-query');
      input.value = 'hor';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      await flushUpdates();
      return input;
    }

    it('dismisses suggestions before closing the panel on a second Escape', async () => {
      const input = await typeQuery();
      populateSuggestions([{ text: 'horses' }]);
      await flushUpdates();
      expect(input.getAttribute('aria-expanded')).toEqual('true');

      windowKeydown('Escape', { target: input, keyCode: 27 });
      await flushUpdates();

      expect(input.getAttribute('aria-expanded')).toEqual('false');
      expect(panel().hidden).toBe(false);
      expect(document.activeElement).toEqual(input);
      expect(cookieManager.getCommoditySearchOpen()).toEqual('open');

      windowKeydown('Escape', { target: input, keyCode: 27 });

      expect(panel().hidden).toBe(true);
      expect(document.activeElement).toEqual(trigger());
      expect(cookieManager.getCommoditySearchOpen()).toEqual('closed');
    });

    it('focuses the editable input when a suggestion arrives after closing', async () => {
      const input = await typeQuery();
      clickTrigger();
      populateSuggestions([{ text: 'horses' }]);
      await flushUpdates();
      expect(panel().querySelector('input[readonly]')).not.toBeNull();

      clickTrigger();

      expect(panel().hidden).toBe(false);
      expect(document.activeElement).toEqual(input);
    });
  });

  describe('keydown', () => {
    beforeEach(() => {
      cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
    });

    it('activates the trigger with Space', async () => {
      await render();
      trigger().focus();

      const event = windowKeydown(' ', { target: trigger() });

      expect(event.defaultPrevented).toBe(true);
      expect(panel().hidden).toBe(false);
      expect(document.activeElement).toEqual(document.getElementById('revised-keyword-query'));
      expect(cookieManager.getCommoditySearchOpen()).toEqual('open');
    });

    it('does not toggle twice when Enter activates the link click', async () => {
      await render();
      trigger().focus();
      clickTrigger();

      windowKeydown('Enter', { target: trigger() });

      // Enter must rely on the browser click activation, so the panel stays
      // open rather than toggling closed by the keydown handler.
      expect(panel().hidden).toBe(false);
    });

    it('closes on Escape from inside the panel and returns focus to the trigger', async () => {
      await render();
      clickTrigger();

      windowKeydown('Escape', { target: document.getElementById('revised-keyword-query') });

      expect(panel().hidden).toBe(true);
      expect(document.activeElement).toEqual(trigger());
      expect(cookieManager.getCommoditySearchOpen()).toEqual('closed');
    });

    it('ignores Escape when the panel is closed', async () => {
      await render();
      document.body.focus();

      windowKeydown('Escape', { target: document.body });

      expect(panel().hidden).toBe(true);
      expect(document.activeElement).not.toEqual(trigger());
    });
  });
});
