require 'spec_helper'

RSpec.describe Commodity do
  subject(:commodity) { build(:commodity) }

  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        ancestors
        chapter
        export_measures
        footnotes
        heading
        import_measures
        import_trade_summary
        overview_measures
        section
      ]
    end

    before do
      allow(Rails.cache).to receive(:fetch).and_call_original
    end

    it { expect(described_class.relationships).to match_array(expected_relationships) }
  end

  it_behaves_like 'a declarable' do
    subject(:declarable) { build(:commodity, import_measures: measures, footnotes:) }
  end

  describe 'parent/children relationships' do
    let(:heading) { build :heading, :with_commodity_tree }

    describe '#children' do
      it 'returns list of commodities children' do
        heading

        expect(heading.commodities.first.children).to include heading.commodities.last
      end

      it 'returns empty array if commodity does not have children' do
        heading

        expect(heading.commodities.last.children).to be_blank
      end
    end

    describe '#root' do
      it 'returns children that have no parent_sid set' do
        heading

        root_children = heading.commodities.select(&:root)

        expect(root_children).to eq([heading.commodities.first])
      end
    end

    describe '#leaf?' do
      context 'when a leaf commodity' do
        subject(:commodity) { heading.commodities.last }

        it { is_expected.to be_leaf }
      end

      context 'when a NON leaf commodity' do
        subject(:commodity) { heading.commodities.first }

        it { is_expected.not_to be_leaf }
      end
    end
  end

  describe '#to_param' do
    let(:commodity) { described_class.new(attributes_for(:commodity)) }

    it 'returns commodity code as param' do
      expect(commodity.to_param).to eq commodity.code
    end
  end

  describe '#aria_label' do
    let(:commodity) { described_class.new(attributes_for(:commodity)) }

    it 'formats the aria label correctly' do
      expect(commodity.aria_label).to \
        eq("Commodity code #{commodity.goods_nomenclature_item_id}, #{commodity.description}")
    end

    context 'when the description is nil' do
      before do
        commodity.description = nil
      end

      it 'does not propagate an exception' do
        expect { commodity.aria_label }.not_to raise_exception
      end
    end
  end

  describe '#heading?' do
    it { is_expected.not_to be_heading }
  end

  describe '#meursing_code?' do
    subject(:commodity) { described_class.new(attributes_for(:commodity, meta: commodity_metadata)) }

    let(:commodity_metadata) do
      { 'duty_calculator' => { 'meursing_code' => meursing_code } }
    end

    context 'when the commodity has a meursing code' do
      let(:meursing_code) { true }

      it 'returns true' do
        expect(commodity).to be_meursing_code
      end
    end

    context 'when the commodity does not have a meursing code' do
      let(:meursing_code) { false }

      it 'returns false' do
        expect(commodity).not_to be_meursing_code
      end
    end
  end

  describe '#calculate_duties?' do
    subject(:commodity) { described_class.new(attributes_for(:commodity, meta: commodity_metadata)) }

    let(:commodity_metadata) { { 'duty_calculator' => { 'entry_price_system' => entry_price_system } } }
    let(:entry_price_system) { false }

    context 'when the commodity should calculate duties' do
      let(:entry_price_system) { false }

      it { is_expected.to be_calculate_duties }
    end

    context 'when the commodity has measures that use the Entry Price System' do
      let(:entry_price_system) { true }

      it { is_expected.not_to be_calculate_duties }
    end
  end

  describe '#commodity_code_for_check_duties_service' do
    subject(:commodity) { build(:commodity, goods_nomenclature_item_id: commodity_code) }

    context 'when commodity code has 4 ending zeros' do
      let(:commodity_code) { '1234560000' }

      it 'strips out all 4 zeros' do
        expect(commodity.commodity_code_for_check_duties_service).to eq('123456')
      end
    end

    context 'when commodity code has 3 ending zeros' do
      let(:commodity_code) { '123456000' }

      it 'strips out only 2 zeros' do
        expect(commodity.commodity_code_for_check_duties_service).to eq('1234560')
      end
    end
  end

  describe 'umbrella_code?' do
    subject { commodity.umbrella_code? }

    let(:heading) { build :heading, commodities: [parent, child] }
    let(:parent) { attributes_for :commodity, producline_suffix: }
    let(:child) do
      attributes_for :commodity, producline_suffix:,
                                 parent_sid: parent[:goods_nomenclature_sid]
    end

    context 'with a commodity without children' do
      let(:commodity) { heading.commodities.last }

      context 'with producline_suffix of 10' do
        let(:producline_suffix) { '10' }

        it { is_expected.to be false }
      end

      context 'with producline_suffix of 80' do
        let(:producline_suffix) { '80' }

        it { is_expected.to be false }
      end
    end

    context 'with a commodity with children' do
      let(:commodity) { heading.commodities.first }

      context 'with producline_suffix of 10' do
        let(:producline_suffix) { '10' }

        it { is_expected.to be true }
      end

      context 'with producline_suffix of 80' do
        let(:producline_suffix) { '80' }

        it { is_expected.to be false }
      end
    end
  end

  describe '#has_safeguarding_measure?' do
    subject { build :commodity, import_measures: [vat, measure] }

    let(:vat) { attributes_for :measure, :vat }

    context 'with safeguarding measures' do
      let(:measure) { attributes_for :measure, :safeguard }

      it { is_expected.to be_has_safeguard_measure }
    end

    context 'without safeguarding measure' do
      let(:measure) { attributes_for :measure, :vat_zero }

      it { is_expected.not_to be_has_safeguard_measure }
    end
  end

  describe '#descriptions_with_other_handling' do
    subject(:descriptions_with_other_handling) do
      build(:commodity, ancestors:, formatted_description:).descriptions_with_other_handling
    end

    context 'when the commodity does not have `other` as a description' do
      let(:formatted_description) { 'Mules' }

      let(:ancestors) do
        [
          attributes_for(:chapter, formatted_description: 'Live animals '),
          attributes_for(:heading, formatted_description: 'Live horses, asses, mules and hinnies '),
          attributes_for(:subheading, formatted_description: 'Horses'),
        ]
      end

      it { is_expected.to eq([]) }
    end

    context 'when the subheading has a non other description' do
      let(:formatted_description) { 'Other' }
      let(:ancestors) do
        [
          attributes_for(:chapter, formatted_description: 'Live animals '),
          attributes_for(:heading, formatted_description: 'Live horses, asses, mules and hinnies '),
          attributes_for(:subheading, formatted_description: 'Horses'),
        ]
      end

      it { is_expected.to eq(%w[Horses]) }
    end

    context 'when the heading has the non other description' do
      let(:formatted_description) { 'Other' }
      let(:ancestors) do
        [
          attributes_for(:chapter, formatted_description: 'Live animals '),
          attributes_for(:heading, formatted_description: 'Live horses, asses, mules and hinnies'),
          attributes_for(:subheading, formatted_description: 'Other'),
          attributes_for(:subheading, formatted_description: 'Other'),
        ]
      end

      it { is_expected.to eq(['Live horses, asses, mules and hinnies', 'Other', 'Other']) }
    end
  end
end
