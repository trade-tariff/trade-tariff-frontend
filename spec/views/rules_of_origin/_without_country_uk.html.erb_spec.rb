require 'spec_helper'

RSpec.describe 'rules_of_origin/_without_country_uk', type: :view do
  subject(:rendered_page) { render && rendered }

  context 'with UK service' do
    include_context 'with UK service'

    it 'references the UK service' do
      expect(rendered_page).to have_css 'p', text: 'Origin allows for various policy measures to be implemented'
    end

    it 'includes additional link' do
      expect(rendered_page).to have_css 'p a', text: 'Find out more about origin'
    end

    it 'includes the preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__preferential'
    end

    it 'includes the non-preferential bloc' do
      expect(rendered_page).to have_css '.rules-of-origin__non-preferential'
    end
  end
end
