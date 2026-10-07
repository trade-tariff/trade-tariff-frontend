/* eslint-env node, jest */

import accessibleAutocomplete from 'accessible-autocomplete';
import '../../app/javascript/src/country-of-origin';

const importDetailsId = 'duty-calculator-steps-import-details-country-of-origin-field';
const legacyId = 'duty-calculator-steps-country-of-origin-country-of-origin-field';
const countryLists = {
  UK: [['FR', 'France (FR)'], ['CN', 'China (CN)']],
  XI: [['GB', 'United Kingdom (GB)'], ['CN', 'China (CN)']],
};

function renderPage(country = '', fieldId = importDetailsId) {
  document.body.innerHTML = `
    <form>
      <input type="radio" name="duty_calculator_steps_import_details[import_destination]" value="UK" checked>
      <input type="radio" name="duty_calculator_steps_import_details[import_destination]" value="XI">
      <div id="import-details-country">
        <label for="${fieldId}">Country of origin</label>
        <select id="${fieldId}" name="country_of_origin">
          <option value=""></option>
          <option value="FR">France (FR)</option>
          <option value="CN">China (CN)</option>
        </select>
      </div>
    </form>
  `;
  document.querySelector('#import-details-country').dataset.countryLists = JSON.stringify(countryLists);
  document.querySelector('select').value = country;
  if (fieldId === legacyId) document.querySelector('#import-details-country').removeAttribute('id');
  document.dispatchEvent(new Event('DOMContentLoaded'));
}

function changeDestination(destination) {
  const radio = document.querySelector(`input[type="radio"][value="${destination}"]`);
  radio.checked = true;
  radio.dispatchEvent(new Event('change', { bubbles: true }));
}

describe('country of origin autocomplete', () => {
  beforeEach(() => {
    window.GOVUK = { accessibleAutocomplete };
  });

  afterEach(() => {
    document.body.innerHTML = '';
    delete window.GOVUK;
  });

  it.each([importDetailsId, legacyId])('shows the selected country for %s', (fieldId) => {
    renderPage('FR', fieldId);

    expect(document.getElementById(fieldId).value).toBe('France (FR)');
    expect(new FormData(document.querySelector('form')).get('country_of_origin')).toBe('FR');
  });

  it('leaves an unselected country blank', () => {
    renderPage();

    expect(document.getElementById(importDetailsId).value).toBe('');
    expect(document.querySelector('select').value).toBe('');
  });

  it('replaces the country list for the destination', () => {
    renderPage();
    changeDestination('XI');

    expect(Array.from(document.querySelector('select').options, (option) => [option.value, option.text]))
      .toEqual([['', ''], ...countryLists.XI]);
  });

  it('retains a country valid for the new destination', () => {
    renderPage('CN');
    changeDestination('XI');

    expect(document.getElementById(importDetailsId).value).toBe('China (CN)');
    expect(new FormData(document.querySelector('form')).get('country_of_origin')).toBe('CN');
  });

  it('clears a country invalid for the new destination', () => {
    renderPage('FR');
    changeDestination('XI');

    expect(document.getElementById(importDetailsId).value).toBe('');
    expect(new FormData(document.querySelector('form')).get('country_of_origin')).toBe('');
  });

  it('replaces the autocomplete without duplicate controls', () => {
    renderPage('CN');
    const originalInput = document.getElementById(importDetailsId);
    changeDestination('XI');
    changeDestination('UK');

    expect(document.body.contains(originalInput)).toBe(false);
    expect(document.querySelectorAll('.autocomplete__wrapper')).toHaveLength(1);
    expect(document.querySelectorAll(`#${importDetailsId}`)).toHaveLength(1);
    expect(document.querySelector('label').htmlFor).toBe(importDetailsId);
    expect(document.getElementById(importDetailsId).value).toBe('China (CN)');
    expect(document.getElementById(`${importDetailsId}-select`).style.display).toBe('none');
  });
});
