require 'spec_helper'

RSpec.describe 'errors/not_found.html.erb', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let(:render_page) { render template: 'errors/not_found' }

  describe 'page content' do
    it { is_expected.to have_css 'h1', text: 'Page not found' }
    it { is_expected.to have_css 'p', text: 'If you entered a web address please check it was correct.' }
    it { is_expected.to have_css 'p', text: 'You can also:' }

    context 'with UK service' do
      include_context 'with UK service'

      it { is_expected.to have_link 'Search for a commodity', href: '/find_commodity' }
      it { is_expected.to have_link 'Browse through the goods classification', href: '/browse' }
      it { is_expected.to have_link 'Use the A-Z of classified goods', href: '/a-z-index/a' }
    end

    context 'with XI service' do
      include_context 'with XI service'

      it { is_expected.to have_link 'Search for a commodity', href: '/xi/find_commodity' }
      it { is_expected.to have_link 'Browse through the goods classification', href: '/xi/browse' }
      it { is_expected.to have_link 'Use the A-Z of classified goods', href: '/xi/a-z-index/a' }
    end
  end
end
