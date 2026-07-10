require 'spec_helper'

RSpec.describe 'shared/search/_search_form', type: :view do
  subject(:rendered_form) do
    render partial: 'shared/search/search_form'
    rendered
  end

  before do
    assign(:search, build(:search))
  end

  it 'submits searches with POST' do
    expect(rendered_form).to have_css('form#new_search[method="post"][action="/search"]')
  end

  context 'when invalid date params are present on the page' do
    before do
      view.params[:invalid_date] = 'true'
      view.params[:day] = '22'
      view.params[:month] = '0'
      view.params[:year] = '2026'
    end

    it 'still posts to a clean search path without stale date query params' do
      expect(rendered_form).to have_css('form#new_search[action="/search"]')
    end
  end

  it 'renders a govuk submit button that keeps browser validation enabled' do
    expect(rendered_form).to have_css('button.govuk-button[type="submit"][name="new_search"][value="Search"]', text: 'Search')
  end

  it 'does not add formnovalidate to the shared search submit button' do
    expect(rendered_form).not_to have_css('button[formnovalidate]')
  end

  it 'renders the noscript autocomplete fallback as a plain text input' do
    expect(rendered_form).to have_css('noscript input#search-q-field[type="text"]:not([role])', visible: :all)
  end

  it 'does not render fallback combobox roles outside the enhanced autocomplete' do
    expect(rendered_form).not_to include('role="combobox"')
  end

  it 'configures debounce with an options object for debounce@3 compatibility' do
    # debounce@3 throws if the third argument is a boolean, which caused the
    # accessible autocomplete init try/catch to fall back to a plain input.
    expect(rendered_form).to include('}, 200, { immediate: false })')
  end

  context 'when shared search button text is not used' do
    before do
      assign(:no_shared_search, true)
    end

    it 'renders the full-width submit button with validation enabled' do
      expect(rendered_form).to have_css('button.govuk-button[type="submit"][name="new_search"][value="Search for a commodity"]', text: 'Search for a commodity')
    end

    it 'adds the wide spacing class to the commodity search submit button' do
      expect(rendered_form).to include('govuk-!-margin-top-6')
    end

    it 'does not add formnovalidate to the commodity search submit button' do
      expect(rendered_form).not_to have_css('button[formnovalidate]')
    end
  end

  context 'when the search has q validation errors' do
    before do
      assign(:search, build(:search, q: '').tap { |search| search.errors.add(:q, 'Enter a search term') })
    end

    it 'renders an inline govuk error message for q' do
      expect(rendered_form).to have_css('.govuk-error-message', text: 'Enter a search term')
    end

    it 'links the label to the autocomplete input id' do
      expect(rendered_form).to have_css('label[for="search-q-field-error"]')
    end

    it 'links the error summary to the autocomplete input id' do
      expect(rendered_form).to have_css('.govuk-error-summary a[href="#search-q-field-error"]', text: 'Enter a search term')
    end

    it 'renders the autocomplete input with the error id' do
      expect(rendered_form).to have_css('noscript input#search-q-field-error[name="q"]', visible: :all)
    end
  end
end
