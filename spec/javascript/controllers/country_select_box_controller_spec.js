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
        <select name="trading_partner[country]" id="trading_partner_country-select" style="display: none;">
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

  it('clears a selected country before processing another click', () => {
    const element = document.querySelector('[data-controller="country-select-box"]');
    const inputElement = element.querySelector('.autocomplete__input');

    inputElement.click();

    expect(inputElement.value).toEqual('');
  });

  it('immediately reopens all options when clicking after a selection', async () => {
    const element = document.querySelector('[data-controller="country-select-box"]');
    const inputElement = element.querySelector('.autocomplete__input');

    inputElement.click();
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(inputElement.value).toEqual('');
    expect(element.querySelectorAll('.autocomplete__option')).toHaveLength(4);
  });

  it('does not clear an unfinished search when clicking the input again', () => {
    const element = document.querySelector('[data-controller="country-select-box"]');
    const inputElement = element.querySelector('.autocomplete__input');

    inputElement.value = 'Tur';
    inputElement.dispatchEvent(new Event('input', {bubbles: true}));
    inputElement.click();

    expect(inputElement.value).toEqual('Tur');
  });

  it('selects a country after typing a search query', async () => {
    const element = document.querySelector('[data-controller="country-select-box"]');
    const inputElement = element.querySelector('.autocomplete__input');
    const selectElement = element.querySelector('select');

    inputElement.click();
    inputElement.value = 'Tur';
    inputElement.dispatchEvent(new Event('input', {bubbles: true}));
    await new Promise((resolve) => setTimeout(resolve, 0));
    element.querySelector('.autocomplete__option').click();
    expect(selectElement.value).toEqual('TR');
    await new Promise((resolve) => setTimeout(resolve, 0));

    expect(inputElement.value).toEqual('Turkey (TR)');
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
