import {Application} from '@hotwired/stimulus';
import CommoditySelectBoxController from 'commodity_select_box_controller';

describe('CommoditySelectBoxController', () => {
  let application;

  beforeAll(() => {
    application = Application.start();
    application.register('commodity-select-box', CommoditySelectBoxController);
  });

  beforeEach(() => {
    document.body.innerHTML = `
    <div data-controller="commodity-select-box">
      <input type="hidden" name="resource_id" id="resource-id-hidden"
      value="6828" data-commodity-select-box-target="resourceIdHidden" autocomplete="off">
      <label class="govuk-label" for="q">Search the UK Integrated Online Tariff</label>
      <div>
        <input id="q" class="autocomplete__input" data-commodity-select-box-target="commodityInput">
      </div>
    </div> `;
  });

  it('should initialize the controller', () => {
    const element = document.querySelector('[data-controller="commodity-select-box"]');
    const controller = application.getControllerForElementAndIdentifier(element, 'commodity-select-box');
    expect(controller).toBeInstanceOf(CommoditySelectBoxController);
  });
});
