require 'spec_helper'

RSpec.describe 'rules_of_origin/_without_country_xi', type: :view do
  subject(:rendered_page) { render && rendered }

  context 'with XI service' do
    include_context 'with XI service'

    it 'references the XI service' do
      expect(rendered_page).to match 'the EU has a trade agreement'
    end

    it 'excludes additional links' do
      expect(rendered_page).not_to have_css 'li a', text: 'Check your goods meet the'
    end

    it 'includes the non-preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__non-preferential'
    end
  end
end
