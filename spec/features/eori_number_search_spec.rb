require 'spec_helper'

RSpec.describe 'EORI number search', :js do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  it 'focuses the search box with the menu closed, so Enter submits the search again' do
    visit find_commodity_path
    # Submit without typing, so no suggestion request opens the menu first.
    page.execute_script(<<~JS)
      const input = document.querySelector('#revised-keyword-query');
      input.value = 'GB123456789000';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      document.querySelector('#new_search').requestSubmit();
    JS

    input = page.find('#search-keyword-q-field-error')
    expect(page).to have_css('.govuk-error-summary', text: 'There is a problem')
    expect(page.evaluate_script('document.activeElement.id')).to eq('search-keyword-q-field-error')
    expect(input['aria-expanded']).to eq('false')
    expect(page).to have_css('.autocomplete__menu--hidden', visible: :all)

    page.execute_script('window.beforeEnter = true')
    input.send_keys(:enter)

    # A new page load clears the marker.
    page.document.synchronize do
      raise Capybara::ExpectationNotMet, 'Enter did not submit' if page.evaluate_script('window.beforeEnter')
    end
    expect(page).to have_css('.govuk-error-summary', text: 'There is a problem')
  end
end
