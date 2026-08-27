import {Application} from '@hotwired/stimulus';
import CommodityPageAnalyticsController from '../../../app/javascript/controllers/commodity_page_analytics_controller';

class MockIntersectionObserver {
  constructor(callback) {
    this.callback = callback;
    this.elements = [];
    MockIntersectionObserver.instance = this;
  }

  observe(element) {
    this.elements.push(element);
  }

  unobserve(element) {
    this.elements = this.elements.filter((observedElement) => observedElement !== element);
  }

  disconnect() {
    this.elements = [];
  }

  expose(element) {
    this.callback([{target: element, isIntersecting: true}]);
  }
}

describe('CommodityPageAnalyticsController', () => {
  let application;

  beforeEach(async () => {
    window.dataLayer = [];
    window.IntersectionObserver = MockIntersectionObserver;

    document.body.innerHTML = `
      <div data-controller="commodity-page-analytics"
           data-commodity-page-analytics-commodity-code-value="0101300000">
        <details data-commodity-page-analytics-target="hierarchy"
                 data-action="toggle->commodity-page-analytics#trackHierarchyToggle click->commodity-page-analytics#trackHierarchyLink">
          <summary>View hierarchy</summary>
          <nav class="commodity-ancestors"><a id="chapter-link" href="/chapters/01">Chapter 01</a></nav>
        </details>

        <form data-commodity-page-analytics-target="tradeDetails"
              data-action="change->commodity-page-analytics#trackTradeDetailsChange submit->commodity-page-analytics#trackTradeDetailsUpdate">
          <select name="country"><option value="FR" selected>France</option></select>
          <input name="day" value="2">
          <input name="month" value="9">
          <input name="year" value="2026">
          <button type="submit">Update page</button>
        </form>

        <div id="calculator"
             data-commodity-page-analytics-target="calculator"
             data-analytics-exposure-event="commodity_duty_calculator_shown">
          <a id="calculator-link" href="/duty-calculator/0101300000/import-date"
             data-action="click->commodity-page-analytics#trackCalculatorClick">Start a duty calculation</a>
        </div>

        <details id="preferential-rates"
                 data-commodity-page-analytics-target="preferentialRates"
                 data-analytics-exposure-event="commodity_preferential_rates_shown"
                 data-analytics-preferential-rates-count="3"
                 data-action="toggle->commodity-page-analytics#trackPreferentialRatesToggle click->commodity-page-analytics#trackPreferentialRatesLink">
          <summary>View 3 preferential rates</summary>
          <a id="rate-link" href="/measure/1">Preferential rate</a>
        </details>

        <section id="import-section"
                 data-commodity-page-analytics-target="tariffSection"
                 data-analytics-exposure-event="commodity_tariff_section_shown"
                 data-analytics-section="import_duties"
                 data-action="click->commodity-page-analytics#trackTariffSectionInteraction">
          <a id="conditions-link" href="#conditions">Conditions</a>
          <a id="rules-of-origin-link" href="#rules-of-origin">Rules of origin</a>
        </section>

        <a id="vat-navigation-link" href="#vat_excise"
           data-action="click->commodity-page-analytics#trackTariffSectionNavigation">Import VAT</a>
      </div>
    `;

    application = Application.start();
    application.register('commodity-page-analytics', CommodityPageAnalyticsController);
    await new Promise((resolve) => setTimeout(resolve, 0));
  });

  afterEach(() => {
    application.stop();
    delete window.dataLayer;
    delete window.IntersectionObserver;
  });

  it('tracks hierarchy and trade-details exposure on page load', () => {
    expect(window.dataLayer).toEqual([
      {event: 'commodity_hierarchy_shown', commodity_code: '0101300000'},
      {event: 'commodity_trade_details_shown', commodity_code: '0101300000'},
    ]);
  });

  it('tracks hierarchy opening, closing, and link clicks', () => {
    const hierarchy = document.querySelector('details');
    const link = document.querySelector('#chapter-link');
    link.addEventListener('click', (event) => event.preventDefault());

    hierarchy.open = true;
    hierarchy.dispatchEvent(new Event('toggle'));
    link.click();
    hierarchy.open = false;
    hierarchy.dispatchEvent(new Event('toggle'));

    expect(window.dataLayer).toEqual(expect.arrayContaining([
      {event: 'commodity_hierarchy_opened', commodity_code: '0101300000'},
      expect.objectContaining({event: 'commodity_hierarchy_link_clicked', link_id: 'chapter-link'}),
      {event: 'commodity_hierarchy_closed', commodity_code: '0101300000'},
    ]));
  });

  it('tracks trade-detail changes and their update sequence', () => {
    const form = document.querySelector('form');
    const country = form.elements.country;
    const day = form.elements.day;
    const importSection = document.querySelector('#import-section');
    const calculatorLink = document.querySelector('#calculator-link');
    calculatorLink.addEventListener('click', (event) => event.preventDefault());
    form.addEventListener('submit', (event) => event.preventDefault());

    country.dispatchEvent(new Event('change', {bubbles: true}));
    window.dispatchEvent(new Event('scroll'));
    day.value = '3';
    day.dispatchEvent(new Event('change', {bubbles: true}));
    MockIntersectionObserver.instance.expose(importSection);
    calculatorLink.click();
    form.dispatchEvent(new Event('submit', {bubbles: true, cancelable: true}));

    expect(window.dataLayer).toEqual(expect.arrayContaining([
      expect.objectContaining({
        event: 'commodity_trade_details_country_changed',
        before_first_scroll: true,
        before_import_duties_or_vat_exposure: true,
        before_calculator_click: true,
      }),
      expect.objectContaining({
        event: 'commodity_trade_details_date_changed',
        field: 'day',
        before_first_scroll: false,
      }),
      expect.objectContaining({
        event: 'commodity_trade_details_update_clicked',
        country_changed: true,
        date_changed: true,
        selected_country: 'FR',
        selected_trade_date: '2026-9-3',
        before_import_duties_or_vat_exposure: false,
        before_calculator_click: false,
      }),
    ]));
  });

  it('tracks calculator, preferential-rate, and tariff-section exposure once', () => {
    const observer = MockIntersectionObserver.instance;
    const calculator = document.querySelector('#calculator');
    const preferentialRates = document.querySelector('#preferential-rates');
    const importSection = document.querySelector('#import-section');

    observer.expose(calculator);
    observer.expose(calculator);
    observer.expose(preferentialRates);
    observer.expose(importSection);

    expect(window.dataLayer.filter(({event}) => event === 'commodity_duty_calculator_shown')).toHaveLength(1);
    expect(window.dataLayer).toEqual(expect.arrayContaining([
      expect.objectContaining({event: 'commodity_preferential_rates_shown', preferential_rates_count: 3}),
      expect.objectContaining({event: 'commodity_tariff_section_shown', section: 'import_duties'}),
    ]));
  });

  it('tracks calculator, preferential-rate, and tariff-section interactions', () => {
    const calculatorLink = document.querySelector('#calculator-link');
    const preferentialRates = document.querySelector('#preferential-rates');
    const rateLink = document.querySelector('#rate-link');
    const conditionsLink = document.querySelector('#conditions-link');
    const rulesOfOriginLink = document.querySelector('#rules-of-origin-link');
    const vatNavigationLink = document.querySelector('#vat-navigation-link');
    [calculatorLink, rateLink, conditionsLink, rulesOfOriginLink, vatNavigationLink].forEach((link) => {
      link.addEventListener('click', (event) => event.preventDefault());
    });

    calculatorLink.click();
    preferentialRates.open = true;
    preferentialRates.dispatchEvent(new Event('toggle'));
    rateLink.click();
    conditionsLink.click();
    rulesOfOriginLink.click();
    vatNavigationLink.click();

    expect(window.dataLayer).toEqual(expect.arrayContaining([
      expect.objectContaining({event: 'commodity_duty_calculator_clicked', link_id: 'calculator-link'}),
      expect.objectContaining({event: 'commodity_preferential_rates_opened', preferential_rates_count: 3}),
      expect.objectContaining({event: 'commodity_preferential_rates_link_clicked', link_id: 'rate-link'}),
      expect.objectContaining({event: 'commodity_tariff_section_interacted', section: 'import_duties'}),
      expect.objectContaining({event: 'commodity_tariff_section_interacted', section: 'vat_excise'}),
      expect.objectContaining({event: 'commodity_rules_of_origin_link_clicked', link_id: 'rules-of-origin-link'}),
    ]));
  });
});
