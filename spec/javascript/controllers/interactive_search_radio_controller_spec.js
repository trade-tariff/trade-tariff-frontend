import { Application } from '@hotwired/stimulus';
import Cookies from 'js-cookie';
import InteractiveSearchRadioController from '../../../app/javascript/controllers/interactive_search_radio_controller';

function buildHTML() {
  return `
    <div class="path_info" data-search-suggestions-path="/search_suggestions.json"></div>

    <div data-controller="interactive-search-radio"
         data-interactive-search-radio-v2-suggestions-path-value="/search_suggestions.json"
         data-interactive-search-radio-interactive-suggestions-path-value="/internal_search_suggestions.json">
      <input id="search_type_guided"
             type="radio"
             name="search_type"
             value="guided"
             aria-controls="conditional-guided"
             data-interactive-search-radio-target="toggle"
             data-action="interactive-search-radio#toggle">

      <div id="conditional-guided"
           class="govuk-radios__conditional govuk-radios__conditional--hidden"
           hidden
           data-interactive-search-radio-target="guidedSection">
        <textarea id="guided_q"
                  name="q"
                  data-interactive-search-radio-target="guidedInput"></textarea>
      </div>

      <input id="search_type_keyword"
             type="radio"
             name="search_type"
             value="keyword"
             aria-controls="conditional-keyword"
             data-interactive-search-radio-target="toggle"
             data-action="interactive-search-radio#toggle">

      <div id="conditional-keyword"
           class="govuk-radios__conditional govuk-radios__conditional--hidden"
           hidden
           data-interactive-search-radio-target="keywordSection">
        <div id="autocomplete">
          <input id="q" name="q">
        </div>
      </div>

      <input type="hidden"
             name="interactive_search"
             value="false"
             data-interactive-search-radio-target="hiddenField">
    </div>
  `;
}

describe('InteractiveSearchRadioController', () => {
  let application;

  async function setup(cookieValue) {
    document.body.innerHTML = buildHTML();

    if (cookieValue === undefined) {
      Cookies.remove('interactive_search');
    } else {
      Cookies.set('interactive_search', cookieValue);
    }

    application = Application.start();
    application.register('interactive-search-radio', InteractiveSearchRadioController);

    await new Promise((resolve) => setTimeout(resolve, 0));
  }

  afterEach(() => {
    Cookies.remove('interactive_search');

    if (application) application.stop();
  });

  it('defaults to keyword search and shows the keyword section', async () => {
    await setup();

    expect(document.querySelector('#search_type_keyword').checked).toBe(true);
    expect(document.querySelector('#conditional-keyword').hidden).toBe(false);
    expect(document.querySelector('#conditional-guided').hidden).toBe(true);
    expect(document.querySelector('#q').disabled).toBe(false);
    expect(document.querySelector('#guided_q').disabled).toBe(true);
  });

  it('restores guided search from the cookie and updates the suggestions path', async () => {
    await setup('true');

    expect(document.querySelector('#search_type_guided').checked).toBe(true);
    expect(document.querySelector('#conditional-guided').hidden).toBe(false);
    expect(document.querySelector('#conditional-keyword').hidden).toBe(true);
    expect(document.querySelector('#guided_q').disabled).toBe(false);
    expect(document.querySelector('#q').disabled).toBe(true);
    expect(document.querySelector('.path_info').dataset.searchSuggestionsPath).toBe('/internal_search_suggestions.json');
    expect(document.querySelector('input[name="interactive_search"]').value).toBe('true');
  });

  it('switches the visible section when the user changes search type', async () => {
    await setup();

    const guidedRadio = document.querySelector('#search_type_guided');
    guidedRadio.click();

    expect(document.querySelector('#conditional-guided').hidden).toBe(false);
    expect(document.querySelector('#conditional-keyword').hidden).toBe(true);
    expect(document.querySelector('#guided_q').disabled).toBe(false);
    expect(document.querySelector('#q').disabled).toBe(true);
    expect(document.querySelector('input[name="interactive_search"]').value).toBe('true');
  });
});
