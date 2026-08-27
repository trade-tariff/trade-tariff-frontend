import {Controller} from '@hotwired/stimulus';

export default class extends Controller {
  static targets = ['calculator', 'hierarchy', 'preferentialRates', 'tariffSection', 'tradeDetails'];
  static values = {commodityCode: String};

  connect() {
    this.changedFields = new Set();
    this.hasScrolled = false;
    this.hasViewedDutiesOrVat = false;
    this.hasClickedCalculator = false;
    this.observedElements = new WeakSet();
    this.markScrolled = () => { this.hasScrolled = true; };

    window.addEventListener('scroll', this.markScrolled, {once: true, passive: true});

    if (!window.dataLayer) return;

    if (this.hasHierarchyTarget) this.#push('commodity_hierarchy_shown');
    if (this.hasTradeDetailsTarget) this.#push('commodity_trade_details_shown');

    this.#observeExposures();
  }

  disconnect() {
    window.removeEventListener('scroll', this.markScrolled);
    this.exposureObserver?.disconnect();
  }

  trackHierarchyToggle(event) {
    this.#push(event.currentTarget.open ? 'commodity_hierarchy_opened' : 'commodity_hierarchy_closed');
  }

  trackHierarchyLink(event) {
    const link = event.target.closest('.commodity-ancestors a');
    if (!link) return;

    this.#push('commodity_hierarchy_link_clicked', this.#linkContext(link));
  }

  trackTradeDetailsChange(event) {
    const field = event.target.name;
    const eventName = field === 'country' ? 'commodity_trade_details_country_changed' : 'commodity_trade_details_date_changed';

    if (field !== 'country' && !['day', 'month', 'year'].includes(field)) return;

    this.changedFields.add(field === 'country' ? 'country' : 'date');

    this.#push(eventName, {
      field,
      value: event.target.value.trim() || 'all',
      ...this.#sequenceContext(),
    });
  }

  trackTradeDetailsUpdate(event) {
    const form = event.currentTarget;

    this.#push('commodity_trade_details_update_clicked', {
      country_changed: this.changedFields.has('country'),
      date_changed: this.changedFields.has('date'),
      selected_country: form.elements.country.value.trim() || 'all',
      selected_trade_date: [form.elements.year.value, form.elements.month.value, form.elements.day.value].join('-'),
      ...this.#sequenceContext(),
    });
  }

  trackCalculatorClick(event) {
    this.hasClickedCalculator = true;
    this.#push('commodity_duty_calculator_clicked', this.#linkContext(event.currentTarget));
  }

  trackPreferentialRatesToggle(event) {
    this.#push(
      event.currentTarget.open ? 'commodity_preferential_rates_opened' : 'commodity_preferential_rates_closed',
      this.#preferentialRatesContext(event.currentTarget),
    );
  }

  trackPreferentialRatesLink(event) {
    const link = event.target.closest('a');
    if (!link) return;

    this.#push('commodity_preferential_rates_link_clicked', {
      ...this.#preferentialRatesContext(event.currentTarget),
      ...this.#linkContext(link),
    });
  }

  trackTariffSectionInteraction(event) {
    const control = event.target.closest('a, button, summary');
    if (!control) return;

    const context = {
      section: event.currentTarget.dataset.analyticsSection,
      control_text: control.textContent.trim(),
      control_url: control.href || undefined,
    };

    this.#push('commodity_tariff_section_interacted', context);

    if (control.matches('a[href$="#rules-of-origin"]')) {
      this.#push('commodity_rules_of_origin_link_clicked', this.#linkContext(control));
    }
  }

  trackTariffSectionNavigation(event) {
    const link = event.currentTarget;

    this.#push('commodity_tariff_section_interacted', {
      section: link.hash.substring(1),
      control_text: link.textContent.trim(),
      control_url: link.href,
    });
  }

  #observeExposures() {
    const elements = [
      ...this.calculatorTargets,
      ...this.preferentialRatesTargets,
      ...this.tariffSectionTargets,
    ];

    if (!('IntersectionObserver' in window)) {
      elements.forEach((element) => this.#trackExposure(element));
      return;
    }

    this.exposureObserver = new window.IntersectionObserver((entries) => {
      entries.filter((entry) => entry.isIntersecting).forEach((entry) => this.#trackExposure(entry.target));
    }, {threshold: 0});

    elements.forEach((element) => this.exposureObserver.observe(element));
  }

  #trackExposure(element) {
    if (this.observedElements.has(element)) return;

    this.observedElements.add(element);
    this.exposureObserver?.unobserve(element);

    const section = element.dataset.analyticsSection;
    if (['import_duties', 'vat_excise'].includes(section)) this.hasViewedDutiesOrVat = true;

    this.#push(element.dataset.analyticsExposureEvent, section ? {section} : this.#preferentialRatesContext(element));
  }

  #preferentialRatesContext(element) {
    const count = Number.parseInt(element.dataset.analyticsPreferentialRatesCount, 10);
    return Number.isNaN(count) ? {} : {preferential_rates_count: count};
  }

  #sequenceContext() {
    return {
      before_first_scroll: !this.hasScrolled,
      before_import_duties_or_vat_exposure: !this.hasViewedDutiesOrVat,
      before_calculator_click: !this.hasClickedCalculator,
    };
  }

  #linkContext(link) {
    return {
      link_id: link.id,
      link_text: link.textContent.trim(),
      link_url: link.href,
    };
  }

  #push(event, context = {}) {
    if (!window.dataLayer || !event) return;

    window.dataLayer.push({
      event,
      commodity_code: this.commodityCodeValue,
      ...context,
    });
  }
}
