require 'spec_helper'

RSpec.describe 'commodities/_ancestors', type: :view do
  subject(:rendered_page) { render_page && rendered }

  let(:render_page) { render 'commodities/ancestors', declarable: declarable }

  context 'with commodity', vcr: { cassette_name: 'commodities_2208909110' } do
    let(:commodity) { Commodity.find('2208909110', as_of: '2018-11-15') }
    let(:declarable) { CommodityPresenter.new commodity }

    let(:row_count) { declarable.ancestors.length + 4 } # Section, Chapter, Heading, Commodity itself

    it { is_expected.to have_css 'nav.commodity-ancestors' }
    it { is_expected.to have_css %(nav[aria-label*="commodity code #{declarable.code}"]) }
    it { is_expected.to have_css 'nav a.govuk-skip-link', text: /commodity #{declarable.code}/ }
    it { is_expected.to have_css 'nav ol li', count: row_count }
    it { is_expected.to have_css 'li span.commodity-ancestors__identifier', count: row_count }
    it { is_expected.to have_css 'li span.commodity-ancestors__descriptor', count: row_count }
    it { is_expected.to have_css 'li#commodity-ancestors__section[aria-owns="commodity-ancestors__chapter"]' }
    it { is_expected.to have_css 'li#commodity-ancestors__chapter[aria-owns="commodity-ancestors__heading"]' }
    it { is_expected.to have_css 'li#commodity-ancestors__heading[aria-owns="commodity-ancestors__ancestor-1"]' }
    it { is_expected.to have_css "li#commodity-ancestors__ancestor-#{declarable.ancestors.length + 1}" }

    it 'includes short heading code' do
      expect(rendered_page).to \
        have_css \
          'li#commodity-ancestors__heading span.segmented-commodity-code span',
          count: 1
    end

    it 'includes full comm code' do
      expect(rendered_page).to \
        have_css \
          "li#commodity-ancestors__ancestor-#{declarable.ancestors.length + 1} span.segmented-commodity-code span",
          count: 3
    end

    it 'links the subheadings' do
      expect(rendered_page).to have_css %(li#commodity-ancestors__ancestor-1 a[href^="/subheadings/"])
    end

    it 'checks the ancestors all chain ownership correctly' do
      declarable.ancestors.each_index do |index|
        expect(rendered_page).to have_css \
          %(li#commodity-ancestors__ancestor-#{index + 1}) +
            %([aria-owns="commodity-ancestors__ancestor-#{index + 2}"])
      end
    end

    context 'with commodity code with multiple trailing zeros' do
      before { allow(commodity).to receive(:code).and_return('2208909100') }

      it 'includes full comm code' do
        expect(rendered_page).to \
          have_css \
            "li#commodity-ancestors__ancestor-#{declarable.ancestors.length + 1} span.segmented-commodity-code span",
            count: 3
      end
    end
  end

  context 'with declarable heading', vcr: { cassette_name: 'headings#show_declarable' } do
    let :declarable do
      HeadingPresenter.new Heading.find('0501')
    end

    it { is_expected.to have_css 'nav.commodity-ancestors' }
    it { is_expected.to have_css %(nav[aria-label*="commodity code #{declarable.code}"]) }
    it { is_expected.to have_css 'nav a.govuk-skip-link', text: /commodity #{declarable.code}/ }
    it { is_expected.to have_css 'nav ol li', count: 3 }
    it { is_expected.to have_css 'li span.commodity-ancestors__identifier', count: 3 }
    it { is_expected.to have_css 'li span.commodity-ancestors__descriptor', count: 3 }
    it { is_expected.to have_css 'li#commodity-ancestors__section[aria-owns="commodity-ancestors__chapter"]' }
    it { is_expected.to have_css 'li#commodity-ancestors__chapter[aria-owns="commodity-ancestors__heading"]' }
    it { is_expected.to have_css 'li#commodity-ancestors__heading' }

    it 'renders as full heading code' do
      expect(rendered_page).to \
        have_css \
          'li#commodity-ancestors__heading span.segmented-commodity-code span',
          count: 3
    end
  end
end
