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

  it 'renders a govuk submit button that keeps browser validation enabled' do
    expect(rendered_form).to have_css('button.govuk-button[type="submit"][name="new_search"][value="Search for a commodity"]', text: 'Search for a commodity')
  end

  it 'does not add formnovalidate to the shared search submit button' do
    expect(rendered_form).not_to have_css('button[formnovalidate]')
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
  end
end
