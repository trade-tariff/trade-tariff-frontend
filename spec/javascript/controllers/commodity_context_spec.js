import {Application} from '@hotwired/stimulus';
import Controller from '../../../app/javascript/controllers/commodity_page_analytics_controller';
import CookieManager from 'cookie-manager';
const flush=()=>new Promise(r=>setTimeout(r,0));
describe('AI-1471 semantic context contract',()=>{
 let app;
 beforeEach(()=>{window.dataLayer=[];new CookieManager().setCookiesPolicy({usage:true,remember_settings:true});new CookieManager().clearCommodityHierarchyOpen();app=Application.start();app.register('commodity-page-analytics',Controller);});
 afterEach(async()=>{document.body.innerHTML='';await flush();app.stop();delete window.IntersectionObserver;});
 async function mount(context,attribute='classic'){
  document.body.innerHTML=`<script type="application/json" id="search-analytics-context">${JSON.stringify(context)}</script><div data-controller="commodity-page-analytics" data-commodity-page-analytics-commodity-code-value="0201100021" data-commodity-page-analytics-search-experience-value="${attribute}"><details data-commodity-page-analytics-target="hierarchy"><summary>Hierarchy</summary></details></div>`;
  await flush();
 }
 it.each(['classic','guided_beta'])('uses semantic JSON %s even when search_state is null',async search_experience=>{
  await mount({search_experience,search_state:null});
  expect(window.dataLayer.find(x=>x.event==='commodity_page_viewed')).toMatchObject({commodity_code:'0201100021',search_experience});
 });
 it('does not mistake consent-time manual state for the initial default',async()=>{
  new CookieManager().setCookiesPolicy({usage:false,remember_settings:true});await mount({search_experience:'classic'});
  document.querySelector('details').open=true;
  new CookieManager().setCookiesPolicy({usage:true,remember_settings:true});await flush();
  expect(window.dataLayer.find(x=>x.event==='commodity_hierarchy_shown')).toMatchObject({initial_state:'closed',state_source:'default'});
 });
 it('does not classify missing direct-arrival context as classic',async()=>{
  await mount({},'');expect(window.dataLayer.find(x=>x.event==='commodity_page_viewed').search_experience).toBe('unknown');
 });
 it('does not persist activity without consent and clears the counter on withdrawal',async()=>{
  new CookieManager().setCookiesPolicy({usage:false,remember_settings:true});await mount({search_experience:'classic'});
  expect(window.localStorage.getItem('ott.commodity.active-days.v1')).toBeNull();
  new CookieManager().setCookiesPolicy({usage:true,remember_settings:true});await flush();
  expect(window.dataLayer.find(x=>x.event==='commodity_page_viewed').commodity_active_days_28d).toBe(1);
  new CookieManager().setCookiesPolicy({usage:false,remember_settings:true});
  expect(window.localStorage.getItem('ott.commodity.active-days.v1')).toBeNull();
 });
 it('restores the consented day counter on regrant without duplicating the page denominator',async()=>{
  await mount({search_experience:'classic'});
  new CookieManager().setCookiesPolicy({usage:false,remember_settings:true});
  expect(window.localStorage.getItem('ott.commodity.active-days.v1')).toBeNull();
  new CookieManager().setCookiesPolicy({usage:true,remember_settings:true});await flush();
  expect(JSON.parse(window.localStorage.getItem('ott.commodity.active-days.v1'))).toHaveLength(1);
  expect(window.dataLayer.filter(x=>x.event==='commodity_page_viewed')).toHaveLength(1);
 });
});
