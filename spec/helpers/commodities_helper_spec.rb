require 'spec_helper'

RSpec.describe CommoditiesHelper, type: :helper do
  describe '#commodity_code' do
    before do
      assign(:heading, heading)
      assign(:commodity, commodity)
    end

    let(:heading) { nil }
    let(:commodity) { nil }

    context 'when the heading is set' do
      let(:heading) { instance_double('Heading', code: '1245000000') }

      it 'returns the correct commodity code' do
        expect(helper.commodity_code).to eq('1245000000')
      end
    end

    context 'when the commodity is set' do
      let(:commodity) { instance_double('Commodity', code: '0987654321') }

      it 'returns the correct commodity code' do
        expect(helper.commodity_code).to eq('0987654321')
      end
    end
  end

  describe '#footnote_heading' do
    context 'when a heading is passed' do
      let(:declarable) { HeadingPresenter.new(build(:heading)) }

      it 'returns the correct footnote heading' do
        expect(helper.footnote_heading(declarable)).to eq(
          'Footnotes for heading 0101000000',
        )
      end
    end

    context 'when a commodity is passed' do
      let(:declarable) { CommodityPresenter.new(build(:commodity)) }

      it 'returns the correct footnote heading' do
        expect(helper.footnote_heading(declarable)).to eq(
          'Footnotes for commodity 0101300000',
        )
      end
    end
  end

  describe '#four_four_two_commodity_code' do
    subject { four_four_two_commodity_code '0123456789' }

    it { is_expected.to have_css 'span.commodity-code-4-4-2 span', count: 3 }
    it { is_expected.to have_css 'span span:nth-of-type(1)', text: '0123' }
    it { is_expected.to have_css 'span span:nth-of-type(2)', text: '4567' }
    it { is_expected.to have_css 'span span:nth-of-type(3)', text: '89' }

    context 'with already segmented code' do
      subject { four_four_two_commodity_code '0123 4567 89' }

      it { is_expected.to have_css 'span.commodity-code-4-4-2 span', count: 3 }
      it { is_expected.to have_css 'span span:nth-of-type(1)', text: '0123' }
      it { is_expected.to have_css 'span span:nth-of-type(2)', text: '4567' }
      it { is_expected.to have_css 'span span:nth-of-type(3)', text: '89' }
    end

    context 'with a heading' do
      subject { four_four_two_commodity_code '0123' }

      it { is_expected.to have_css 'span.commodity-code-4-4-2 span', count: 1 }
      it { is_expected.to have_css 'span span:nth-of-type(1)', text: '0123' }
    end

    context 'with a chapter' do
      subject { four_four_two_commodity_code '01' }

      it { is_expected.to have_css 'span.commodity-code-4-4-2 span', count: 1 }
      it { is_expected.to have_css 'span span:nth-of-type(1)', text: '01' }
    end

    context 'with nothing' do
      subject { four_four_two_commodity_code '' }

      it { is_expected.to be_nil }
    end
  end
end
