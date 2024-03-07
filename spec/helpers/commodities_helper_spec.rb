require 'spec_helper'

RSpec.describe CommoditiesHelper, type: :helper do
  describe '#footnote_heading' do
    context 'when a heading is passed' do
      let(:declarable) { HeadingPresenter.new(build(:heading)) }

      it 'returns the correct footnote heading' do
        expect(helper.footnote_heading(declarable)).to eq(
          'Notes for heading 0101000000',
        )
      end
    end

    context 'when a commodity is passed' do
      let(:declarable) { CommodityPresenter.new(build(:commodity)) }

      it 'returns the correct footnote heading' do
        expect(helper.footnote_heading(declarable)).to eq(
          "Notes for commodity #{declarable.goods_nomenclature_item_id}",
        )
      end
    end
  end

  describe '#divide_commodity_code' do
    subject { divide_commodity_code comm_code }

    let(:comm_code) { '0123456789' }

    it { is_expected.to eql %w[0123 4567 89] }

    context 'with blank comm code' do
      let(:comm_code) { '' }

      it { is_expected.to be_nil }
    end

    context 'with already divided comm code' do
      let(:comm_code) { '0123 4567 89' }

      it { is_expected.to eql %w[0123 4567 89] }
    end

    context 'with a heading' do
      let(:comm_code) { '0123' }

      it { is_expected.to eql %w[0123] }
    end

    context 'with an 8 digit code' do
      let(:comm_code) { '01234567' }

      it { is_expected.to eql %w[0123 4567] }
    end
  end

  describe '#segmented_commodity_code' do
    subject { segmented_commodity_code comm_code }

    let(:comm_code) { '0123456789' }

    it { is_expected.to have_css 'span.segmented-commodity-code span', count: 3 }
    it { is_expected.to have_css 'span span:nth-of-type(1)', text: '0123' }
    it { is_expected.to have_css 'span span:nth-of-type(2)', text: '4567' }
    it { is_expected.to have_css 'span span:nth-of-type(3)', text: '89' }

    context 'with already segmented code' do
      let(:comm_code) { '0123 4567 89' }

      it { is_expected.to have_css 'span.segmented-commodity-code span', count: 3 }
      it { is_expected.to have_css 'span span:nth-of-type(1)', text: '0123' }
      it { is_expected.to have_css 'span span:nth-of-type(2)', text: '4567' }
      it { is_expected.to have_css 'span span:nth-of-type(3)', text: '89' }
    end

    context 'with a heading' do
      let(:comm_code) { '0123' }

      it { is_expected.to have_css 'span.segmented-commodity-code span', count: 1 }
      it { is_expected.to have_css 'span span:nth-of-type(1)', text: '0123' }
    end

    context 'with a chapter' do
      let(:comm_code) { '01' }

      it { is_expected.to have_css 'span.segmented-commodity-code span', count: 1 }
      it { is_expected.to have_css 'span span:nth-of-type(1)', text: '01' }
    end

    context 'with nothing' do
      let(:comm_code) { '' }

      it { is_expected.to be_nil }
    end

    context 'with an 8 digit code' do
      let(:comm_code) { '01234567' }

      it { is_expected.to have_css 'span.segmented-commodity-code span', count: 2 }
      it { is_expected.to have_css 'span span:nth-of-type(1)', text: '0123' }
      it { is_expected.to have_css 'span span:nth-of-type(2)', text: '4567' }
    end

    context 'with coloured codes' do
      subject(:output) { segmented_commodity_code comm_code, coloured: true }

      it 'includes the coloured modifier class' do
        expect(output).to have_css \
          'span.segmented-commodity-code.segmented-commodity-code--coloured span',
          count: 3
      end
    end
  end

  describe '#abbreviate_commodity_code' do
    subject { abbreviate_commodity_code commodity }

    let(:commodity_code_long_format) { '0123456700' }

    let(:commodity) do
      build(:commodity, goods_nomenclature_item_id: commodity_code_long_format, declarable:)
    end

    context('when commodity is declarable') do
      let(:declarable) { true }

      it { is_expected.to eql commodity_code_long_format }
    end

    context('when commodity is NOT declarable') do
      let(:declarable) { false }

      it { is_expected.not_to eql commodity_code_long_format }
    end
  end

  describe '#abbreviate_code' do
    subject { abbreviate_code(code) }

    shared_examples 'an abbreviated code' do |original, abbreviated|
      let(:code) { original }

      it { is_expected.to eql abbreviated }
    end

    it_behaves_like 'an abbreviated code', '0123400000', '012340'
    it_behaves_like 'an abbreviated code', '0123450000', '012345'
    it_behaves_like 'an abbreviated code', '0123456000', '01234560'
    it_behaves_like 'an abbreviated code', '0123456700', '01234567'
    it_behaves_like 'an abbreviated code', '0123456780', '0123456780'
    it_behaves_like 'an abbreviated code', '0123456789', '0123456789'
    it_behaves_like 'an abbreviated code', '0123456789-10', '0123456789'
  end

  describe '#commodity_ancestor_id' do
    subject { commodity_ancestor_id 23 }

    it { is_expected.to eql 'commodity-ancestors__ancestor-23' }
  end

  describe '#convert_text_to_links' do
    subject { helper.convert_text_to_links declarable_formatted_description }

    before do
      allow(helper).to receive(:url_options).and_return(country: 'IN',
                                                        year: '2022',
                                                        month: '12',
                                                        day: '01')
    end

    context 'with blank formatted description' do
      let(:declarable_formatted_description) { '' }

      it { is_expected.to be_empty }
    end

    context 'with chemical references in formatted description' do
      let(:declarable_formatted_description) { 'CAS RN 7439-93-2' }

      it { is_expected.to eql 'CAS RN 7439-93-2' }
    end

    context 'with chapter in formatted description' do
      let(:declarable_formatted_description) { ' Chapter 32.' }

      it { is_expected.to eql " <a href='/search?q=32&country=IN&day=01&month=12&year=2022'>Chapter 32</a>." }
    end

    context 'with heading in formatted description' do
      let(:declarable_formatted_description) { ' 1234<br>' }

      it { is_expected.to eql " <a href='/search?q=1234&country=IN&day=01&month=12&year=2022'>1234</a><br>" }
    end

    context 'with 8 digit subheading in formatted description' do
      let(:declarable_formatted_description) { ' 1234 11 22' }

      it { is_expected.to eql " <a href='/search?q=12341122&country=IN&day=01&month=12&year=2022'>1234 11 22</a>" }
    end

    context 'with 6 digit subheading in formatted description' do
      let(:declarable_formatted_description) { ' 1234 11, flibble' }

      it { is_expected.to eql " <a href='/search?q=123411&country=IN&day=01&month=12&year=2022'>1234 11</a>, flibble" }
    end
  end

  describe '#query' do
    subject(:query) { helper.query }

    before do
      allow(helper).to receive(:url_options).and_return(url_options)
    end

    context 'when there are no applicable query params' do
      let(:url_options) { {} }

      it { is_expected.to eq('') }
    end

    context 'when there are applicable query params' do
      let(:url_options) do
        {
          country: 'IN',
          year: '2022',
          month: '12',
          day: '01',
        }
      end

      it { is_expected.to eq('&country=IN&day=01&month=12&year=2022') }
    end
  end

  describe '#overview_measure_duty_amounts_for' do
    subject(:overview_measure_duty_amounts_for) { helper.overview_measure_duty_amounts_for(commodity) }

    let(:commodity) { build(:commodity) }

    it { is_expected.to be_html_safe }

    context 'when TradeTariffFrontend::ServiceChooser.uk? is true' do
      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:uk?).and_return(true)
      end

      it { is_expected.to have_css('div.vat') }
    end

    context 'when TradeTariffFrontend::ServiceChooser.uk? is false' do
      before do
        allow(TradeTariffFrontend::ServiceChooser).to receive(:uk?).and_return(false)
      end

      it { is_expected.not_to have_css('div.vat') }
    end

    it { is_expected.to have_css('div.duty') }
    it { is_expected.to have_css('div.supplementary-units') }
    it { is_expected.to have_css('div.identifier') }
  end

  describe '#vat_overview_measure_duty_amounts' do
    subject(:vat_overview_measure_duty_amounts) do
      helper.vat_overview_measure_duty_amounts(commodity)
    end

    context 'when there are no vat overview measures' do
      let(:commodity) { build(:commodity) }

      it { is_expected.to eq('&nbsp;') }
      it { is_expected.to be_html_safe }
    end

    context 'when there is 1 vat overview measure' do
      let(:commodity) { build(:commodity, :with_a_vat_overview_measure) }

      it { is_expected.to eq('20%') }
      it { is_expected.to be_html_safe }
    end

    context 'when there is more than 1 vat overview measure' do
      let(:commodity) { build(:commodity, :with_vat_overview_measures) }

      it { is_expected.to eq('20% or 20%') }
      it { is_expected.to be_html_safe }
    end
  end

  describe '#third_country_overview_measure_duty_amounts' do
    subject(:third_country_overview_measure_duty_amounts) do
      helper.third_country_overview_measure_duty_amounts(commodity)
    end

    context 'when there are no third country overview measures' do
      let(:commodity) { build(:commodity) }

      it { is_expected.to eq('&nbsp;') }
      it { is_expected.to be_html_safe }
    end

    context 'when there are third country overview measures without additional codes' do
      let(:commodity) { build(:commodity, :with_third_country_overview_measures) }

      it { is_expected.to eq('2.00%') }
      it { is_expected.to be_html_safe }
    end

    context 'when there are third country overview measures with additional codes' do
      let(:commodity) { build(:commodity, :with_third_country_overview_measures_with_additional_codes) }

      it { is_expected.to have_css('table') }
    end
  end

  describe '#supplementary_unit_overview_measure_duty_amounts' do
    subject(:supplementary_unit_overview_measure_duty_amounts) do
      helper.supplementary_unit_overview_measure_duty_amounts(commodity)
    end

    context 'when there are no supplementary unit overview measures' do
      let(:commodity) { build(:commodity) }

      it { is_expected.to eq('&nbsp;') }
      it { is_expected.to be_html_safe }
    end

    context 'when there are supplementary unit overview measures' do
      let(:commodity) { build(:commodity, :with_a_supplementary_unit_overview_measure) }

      it { is_expected.to eq('p/st') }
      it { is_expected.to be_html_safe }
    end
  end

  describe '#sanitize_quotes' do
    subject(:sanitize_quotes) { helper.sanitize_quotes(bad_hyperlink) }

    let(:bad_hyperlink) { '<a href=”https://www.gov.uk”>' }

    it 'replaces double comma quotation mark to simple quotation mark' do
      expect(sanitize_quotes).to eq('<a href="https://www.gov.uk">')
    end
  end
end
