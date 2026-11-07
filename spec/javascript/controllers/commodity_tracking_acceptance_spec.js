import {Application} from '@hotwired/stimulus';
import CommodityPageAnalyticsController from '../../../app/javascript/controllers/commodity_page_analytics_controller';
import CookieManager from 'cookie-manager';

const flush = () => new Promise(resolve => setTimeout(resolve, 0));
describe('Commodity tracking release acceptance', () => {
  let app, observers;
  const rows = name => window.dataLayer.filter(row => row.event === name);
  async function mount(experience = 'classic') {
    document.body.innerHTML = `<div data-controller="commodity-page-analytics" data-commodity-page-analytics-commodity-code-value="0101300000" data-commodity-page-analytics-search-experience-value="${experience}">
      <details data-commodity-page-analytics-target="hierarchy"><summary>Hierarchy</summary></details>
      <form id="trade" data-commodity-page-analytics-target="tradeDetails"></form>
      <section id="calc" data-commodity-page-analytics-target="calculator" data-analytics-exposure-event="commodity_duty_calculator_shown"><a href="#" data-action="click->commodity-page-analytics#trackCalculatorClick">Calculate</a></section>
    </div>`;
    await flush();
  }
  beforeEach(() => {
    document.cookie = 'commodity_hierarchy_open=; max-age=0';
    new CookieManager().setCookiesPolicy({usage:true,remember_settings:true});
    window.dataLayer=[]; observers=[];
    window.IntersectionObserver=class {
      constructor(callback, options) {this.callback=callback;this.options=options;this.elements=[];observers.push(this);}
      observe(element) {this.elements.push(element);}
      unobserve() {}
      disconnect() {}
    };
    app=Application.start();app.register('commodity-page-analytics',CommodityPageAnalyticsController);
  });
  afterEach(async () => {document.body.innerHTML='';await flush();app.stop();delete window.IntersectionObserver;});
  it.each(['classic','guided_beta'])('emits a commodity denominator with %s context on every event', async experience => {
    await mount(experience);
    document.querySelector('a').click();
    expect(rows('commodity_page_viewed')).toHaveLength(1);
    expect(window.dataLayer.every(row=>row.search_experience===experience)).toBe(true);
    expect(rows('commodity_duty_calculator_clicked')[0]).toMatchObject({entry_source:'commodity_page'});
  });
  it.each(['open','closed'])('reports saved %s state without a click',async state => {
    new CookieManager().setCommodityHierarchyOpen(state);
    await mount();
    expect(rows('commodity_hierarchy_shown')[0]).toMatchObject({initial_state:state,state_source:'saved_preference'});
    expect(rows('commodity_hierarchy_opened')).toHaveLength(0);
    expect(rows('commodity_hierarchy_closed')).toHaveLength(0);
  });
  it('reports the default separately from a saved preference',async () => {
    await mount();expect(rows('commodity_hierarchy_shown')[0]).toMatchObject({initial_state:'closed',state_source:'default'});
  });
  it('requires at least half of the actual trade/calculator section and emits once',async () => {
    await mount();
    expect(rows('commodity_trade_details_shown')).toHaveLength(0);
    for (const [id,name] of [['trade','commodity_trade_details_shown']]) {
      const element=document.getElementById(id); const observer=observers.find(o=>o.elements.includes(element));
      expect(observer).toBeDefined();expect(observer.options.threshold).toContain(0.5);
      observer.callback([{target:element,isIntersecting:true,intersectionRatio:0.49}]);expect(rows(name)).toHaveLength(0);
      observer.callback([{target:element,isIntersecting:true,intersectionRatio:0.5}]);
      observer.callback([{target:element,isIntersecting:true,intersectionRatio:1}]);expect(rows(name)).toHaveLength(1);
    }
  });
  it('preserves the existing calculator exposure rule while enriching its context',async()=>{
    await mount();const element=document.getElementById('calc');const observer=observers.find(o=>o.elements.includes(element));
    observer.callback([{target:element,isIntersecting:true,intersectionRatio:0.1}]);
    expect(rows('commodity_duty_calculator_shown')).toHaveLength(1);
    expect(rows('commodity_duty_calculator_shown')[0]).toMatchObject({search_experience:'classic'});
  });
  it('does not invent Trade details exposure and preserves other fallback behaviour',async () => {
    delete window.IntersectionObserver;await mount();
    expect(rows('commodity_trade_details_shown')).toHaveLength(0);expect(rows('commodity_duty_calculator_shown')).toHaveLength(1);
  });
  it('suppresses emission on absent/refused consent and after same-document withdrawal',async () => {
    document.cookie='cookies_policy=; max-age=0';await mount();expect(window.dataLayer).toHaveLength(0);
    new CookieManager().setCookiesPolicy({usage:false});document.querySelector('a').click();expect(window.dataLayer).toHaveLength(0);
    new CookieManager().setCookiesPolicy({usage:true});await mount();const count=window.dataLayer.length;
    new CookieManager().setCookiesPolicy({usage:false});document.querySelector('a').click();expect(window.dataLayer).toHaveLength(count);
  });
});
