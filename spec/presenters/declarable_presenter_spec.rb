require 'spec_helper'

RSpec.describe DeclarablePresenter do
  subject(:presenter) { described_class.new(declarable) }

  let(:declarable) { Commodity.new(goods_nomenclature_item_id: '0102210000', formatted_description: 'Fruits &mdash') }

  describe '#heading_code' do
    it { expect(presenter.heading_code).to eq('02') }
  end

  describe '#to_s' do
    it { expect(presenter.to_s).to be_html_safe }
    it { expect(presenter.to_s).to eq('Fruits &mdash') }
  end

  describe '#footnote_heading' do
    context 'when the presenter wraps a heading' do
      subject(:presenter) { HeadingPresenter.new(build(:heading)) }

      it 'returns the footnote heading string for a heading' do
        expect(presenter.footnote_heading).to eq('Notes for heading 0101000000')
      end
    end

    context 'when the presenter wraps a commodity' do
      subject(:presenter) { CommodityPresenter.new(build(:commodity)) }

      it 'returns the footnote heading string for a commodity' do
        expect(presenter.footnote_heading).to eq(
          "Notes for commodity #{presenter.goods_nomenclature_item_id}",
        )
      end
    end
  end

  describe '#format_full_code' do
    subject(:presenter) { CommodityPresenter.new(build(:commodity, goods_nomenclature_item_id: '0101300000')) }

    it 'returns html-safe formatted code with commodity-code structure' do
      result = presenter.format_full_code
      expect(result).to be_html_safe
      expect(result).to include('chapter-code')
      expect(result).to include('heading-code')
      expect(result).to include('commodity-code')
    end
  end

  describe '#format_commodity_code' do
    subject(:presenter) { CommodityPresenter.new(build(:commodity, goods_nomenclature_item_id: '0101300000')) }

    it 'returns html-safe short code with non-breaking spaces' do
      result = presenter.format_commodity_code
      expect(result).to be_html_safe
      expect(result).to include('&nbsp;')
    end
  end

  describe '#format_commodity_code_based_on_level' do
    context 'when number_indents is 1 and producline_suffix is not 80' do
      subject(:presenter) do
        CommodityPresenter.new(
          build(:commodity, number_indents: 1, producline_suffix: '10'),
        )
      end

      it 'returns nil' do
        expect(presenter.format_commodity_code_based_on_level).to be_nil
      end
    end

    context 'when number_indents is greater than 1' do
      subject(:presenter) do
        CommodityPresenter.new(
          build(:commodity, number_indents: 2, producline_suffix: '10'),
        )
      end

      it 'returns html-safe formatted code' do
        result = presenter.format_commodity_code_based_on_level
        expect(result).to be_html_safe
        expect(result).to include('chapter-code')
      end
    end

    context 'when producline_suffix is 80' do
      subject(:presenter) do
        CommodityPresenter.new(
          build(:commodity, number_indents: 1, producline_suffix: '80'),
        )
      end

      it 'returns html-safe formatted code' do
        result = presenter.format_commodity_code_based_on_level
        expect(result).to be_html_safe
      end
    end
  end

  describe '#abbreviate_commodity_code' do
    let(:commodity_code) { '0123456700' }

    context 'when the commodity is declarable' do
      subject(:presenter) do
        CommodityPresenter.new(
          build(:commodity, goods_nomenclature_item_id: commodity_code, declarable: true),
        )
      end

      it 'returns the full code unchanged' do
        expect(presenter.abbreviate_commodity_code).to eql(commodity_code)
      end
    end

    context 'when the commodity is not declarable' do
      subject(:presenter) do
        CommodityPresenter.new(
          build(:commodity, goods_nomenclature_item_id: commodity_code, declarable: false),
        )
      end

      it 'returns an abbreviated code' do
        expect(presenter.abbreviate_commodity_code).not_to eql(commodity_code)
      end
    end
  end
end
