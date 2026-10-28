require 'spec_helper'

RSpec.describe 'EORI number search', :js do
  include_context 'with latest news stubbed'
  include_context 'with news updates stubbed'

  def submit_eori_number(term)
    visit find_commodity_path
    # Submit without typing, so no suggestion request opens the menu first.
    page.execute_script(<<~JS, term)
      const input = document.querySelector('#revised-keyword-query');
      input.value = arguments[0];
      input.dispatchEvent(new Event('input', { bubbles: true }));
      document.querySelector('#new_search').requestSubmit();
    JS
    page.find('#search-keyword-q-field-error')
  end

  def expect_focused_search_box_in_view
    expect(page.evaluate_script('document.activeElement.id')).to eq('search-keyword-q-field-error')
    in_view = page.evaluate_script(<<~JS)
      (() => {
        const box = document.querySelector('#search-keyword-q-field-error').getBoundingClientRect();
        return box.top >= 0 && box.bottom <= window.innerHeight;
      })()
    JS
    expect(in_view).to be(true)
  end

  it 'focuses the search box with the menu closed, so Enter submits the search again' do
    input = submit_eori_number('GB123456789000')

    expect(page).to have_css('.govuk-error-summary', text: 'There is a problem')
    expect(input.value).to eq('GB123456789000')
    expect_focused_search_box_in_view
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

  context 'with AI-assisted search available on a small screen' do
    before do
      enable_feature(:interactive_search)
      page.current_window.resize_to(375, 667)
    end

    after { page.current_window.resize_to(1200, 800) }

    it 'keeps the code or keyword tab open and the focused search box in view' do
      input = submit_eori_number('gb 123 456 789')

      expect(page).to have_link('AI-assisted search')
      expect(page).to have_css('#keyword-search-panel', visible: :visible)
      expect(page).to have_css('#ai-search-panel', visible: :hidden)
      expect(input.value).to eq('gb 123 456 789')
      expect_focused_search_box_in_view
    end
  end
end
