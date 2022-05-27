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
  end

  describe '#commodity_ancestor_id' do
    subject { commodity_ancestor_id 23 }

    it { is_expected.to eql 'commodity-ancestors__ancestor-23' }
  end
end
