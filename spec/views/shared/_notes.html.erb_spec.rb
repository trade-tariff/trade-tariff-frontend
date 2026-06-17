require 'spec_helper'

# rubocop:disable RSpec/DescribeClass
RSpec.describe 'shared/_notes.html.erb' do
  subject(:rendered_page) do
    render partial: 'shared/notes', locals: { chapter_note:, section_note: }
    Capybara.string(rendered)
  end

  let(:chapter_note) { 'Goods of Chapter 7 and heading 1005.' }
  let(:section_note) { nil }

  before do
    allow(TradeTariffFrontend::ServiceChooser).to receive(:xi?).and_return(false)
  end

  context 'when the frontend is not production' do
    before do
      allow(TradeTariffFrontend).to receive(:production?).and_return(false)
    end

    it 'linkifies goods code references' do
      expect(rendered_page).to have_link('7', href: '/search?q=07')
        .and have_link('1005', href: '/search?q=1005')
    end
  end

  context 'when the frontend is production' do
    before do
      allow(TradeTariffFrontend).to receive(:production?).and_return(true)
    end

    it 'does not linkify goods code references' do
      expect(rendered_page).to have_no_link('7', href: '/search?q=07')
        .and have_no_link('1005', href: '/search?q=1005')
    end
  end
end
# rubocop:enable RSpec/DescribeClass
