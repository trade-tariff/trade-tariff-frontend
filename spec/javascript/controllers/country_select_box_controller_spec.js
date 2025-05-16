import {Application} from '@hotwired/stimulus';
import CountrySelectBoxController from '../../../app/javascript/controllers/country_select_box_controller';

describe('CountrySelectBoxController', () => {
  let application;

  beforeAll(() => {
    application = Application.start();
    application.register('country-select-box', CountrySelectBoxController);
  });

  beforeEach(() => {
    document.body.innerHTML = `
     <div data-controller="country-select-box">
      <div data-country-select-box-target="countrySelect">
        <select data-action="focus->country-select-box#clearSelect"
          name="trading_partner[country]" id="trading_partner_country-select" style="display: none;">
          <option value=" ">All countries</option>
          <option selected="selected" value="AF">Afghanistan (AF)</option>
          <option value="TR">Turkey (TR)</option>
          <option value="ZW">Zimbabwe (ZW)</option>
        </select>
      </div>
    </div>
    `;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('clears the select value on focus', () => {
    const element = document.querySelector('[data-controller="country-select-box"]');
    const inputElement = element.querySelector('.autocomplete__input');

    inputElement.value = 'All countries';
    const event = new Event('focus');
    inputElement.dispatchEvent(event);

    expect(inputElement.value).toEqual('');
  });

  it('matches accented characters', () => {
    const element = document.querySelector('[data-controller="country-select-box"]');
    const inputElement = element.querySelector('.autocomplete__input');

    inputElement.value = 'Tü';
    const event = new Event('onKeyDown');
    inputElement.dispatchEvent(event);

    expect(element.querySelector('ul').getElementsByTagName('li').length).toEqual(1);
  });
});
