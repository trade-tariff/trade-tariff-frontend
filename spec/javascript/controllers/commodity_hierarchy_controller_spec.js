import {Application} from '@hotwired/stimulus';
import CommodityHierarchyController from '../../../app/javascript/controllers/commodity_hierarchy_controller';
import CookieManager from '../../../app/javascript/src/cookie-manager';
import Cookies from 'js-cookie';

describe('CommodityHierarchyController', () => {
  let application;
  const cookieManager = new CookieManager();

  function resetCookies() {
    Object.keys(Cookies.get()).forEach((cookieName) => Cookies.remove(cookieName));
  }

  function detailsElement() {
    return document.querySelector('details');
  }

  async function render() {
    document.body.innerHTML = `
      <details data-controller="commodity-hierarchy"
               data-action="toggle->commodity-hierarchy#remember">
        <summary>View Section, Chapter, Heading...</summary>
        <p>Hierarchy</p>
      </details>
    `;

    application = Application.start();
    application.register('commodity-hierarchy', CommodityHierarchyController);
    await new Promise((resolve) => setTimeout(resolve, 0));
    await new Promise((resolve) => setTimeout(resolve, 0));
    return detailsElement();
  }

  function toggle(details, open) {
    details.open = open;
    details.dispatchEvent(new Event('toggle', {bubbles: true}));
  }

  beforeEach(() => {
    resetCookies();
  });

  afterEach(() => {
    application?.stop();
    document.body.innerHTML = '';
    resetCookies();
  });

  it('leaves the details closed and stores nothing when the user has not allowed settings cookies', async () => {
    const details = await render();

    toggle(details, true);

    expect(details.open).toBe(true);
    expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();
  });

  it('does not restore or save a choice when settings consent is malformed', async () => {
    cookieManager.setCookiesPolicy({usage: true, remember_settings: 1});
    cookieManager.setCommodityHierarchyOpen('open');

    const details = await render();

    expect(details.open).toBe(false);
    expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();

    cookieManager.setCookiesPolicy({usage: true, remember_settings: 1});
    toggle(details, true);
    expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();
  });

  it('does not restore a stored choice after the user withdraws settings cookies', async () => {
    cookieManager.setCommodityHierarchyOpen('open');
    cookieManager.setCookiesPolicy({usage: false, remember_settings: false});

    const details = await render();

    expect(details.open).toBe(false);
    expect(cookieManager.getCommodityHierarchyOpen()).toBeNull();
  });

  it('remembers an open choice on the next declarable page', async () => {
    cookieManager.setCookiesPolicy({usage: false, remember_settings: true});
    let details = await render();

    toggle(details, true);
    expect(cookieManager.getCommodityHierarchyOpen()).toEqual('open');

    application.stop();
    details = await render();

    expect(details.open).toBe(true);
    expect(cookieManager.getCommodityHierarchyOpen()).toEqual('open');
  });

  it('remembers a closed choice after the user closes the details', async () => {
    cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
    cookieManager.setCommodityHierarchyOpen('open');
    let details = await render();
    expect(details.open).toBe(true);

    toggle(details, false);
    expect(cookieManager.getCommodityHierarchyOpen()).toEqual('closed');

    application.stop();
    details = await render();

    expect(details.open).toBe(false);
  });

  it('does not treat the queued restore toggle as a new choice', async () => {
    cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
    cookieManager.setCommodityHierarchyOpen('open');
    document.body.innerHTML = `
      <details data-controller="commodity-hierarchy"
               data-action="toggle->commodity-hierarchy#remember">
        <summary>View Section, Chapter, Heading...</summary>
        <p>Hierarchy</p>
      </details>
    `;
    const details = detailsElement();
    let queuedToggle = null;
    let markerDuringToggle = null;

    Object.defineProperty(details, 'open', {
      configurable: true,
      get() {
        return details.hasAttribute('open');
      },
      set(value) {
        if (value) details.setAttribute('open', '');
        else details.removeAttribute('open');
        queuedToggle = () => details.dispatchEvent(new Event('toggle', {bubbles: true}));
      },
    });
    details.addEventListener('toggle', () => {
      markerDuringToggle = details.hasAttribute('data-commodity-hierarchy-restoring');
    });

    application = Application.start();
    application.register('commodity-hierarchy', CommodityHierarchyController);
    await new Promise((resolve) => setTimeout(resolve, 0));
    queuedToggle();

    expect(markerDuringToggle).toBe(true);
    expect(cookieManager.getCommodityHierarchyOpen()).toEqual('open');
    expect(details.hasAttribute('data-commodity-hierarchy-restoring')).toBe(false);

    delete details.open;
    toggle(details, false);
    expect(cookieManager.getCommodityHierarchyOpen()).toEqual('closed');
  });

  it('does not save the toggle fired while restoring a saved choice', async () => {
    cookieManager.setCookiesPolicy({usage: true, remember_settings: true});
    cookieManager.setCommodityHierarchyOpen('closed');
    const details = await render();
    details.setAttribute('data-commodity-hierarchy-restoring', 'true');

    toggle(details, true);

    expect(cookieManager.getCommodityHierarchyOpen()).toEqual('closed');
  });
});
