require 'spec_helper'

RSpec.describe Subheading do
  subject(:heading) { build(:subheading) }

  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        ancestors
        chapter
        commodities
        footnotes
        heading
        section
      ]
    end

    it { expect(described_class.relationships).to match_array(expected_relationships) }
  end

  it { is_expected.to have_attributes(goods_nomenclature_item_id: '0101100000') }
  it { is_expected.to have_attributes(producline_suffix: '10') }
  it { is_expected.to have_attributes(number_indents: 3) }
  it { is_expected.to have_attributes(description: 'Horses') }
  it { is_expected.to have_attributes(formatted_description: '<strong>Horses</strong>') }

  describe '#descendants' do
    context 'when the subheading has descendants' do
      subject(:descendants) { build(:subheading, :with_descendants).descendants }

      it { is_expected.to be_present }
    end

    context 'when the subheading has no descendants' do
      subject(:descendants) { build(:subheading, :without_descendants).descendants }

      it { is_expected.to be_empty }
    end

    context 'when the subheading has no commodities' do
      subject(:descendants) { build(:subheading, :without_commodities).descendants }

      it { is_expected.to be_empty }
    end
  end

  describe '#page_heading' do
    subject(:page_heading) { build(:subheading).page_heading }

    it { is_expected.to eq('Subheading 010110 - <strong>Horses</strong>') }
  end

  describe '#code' do
    context 'when a harmonised system goods_nomenclature_item_id' do
      subject(:code) { build(:subheading, :harmonised_system_code).code }

      it { is_expected.to eq '010110' }
    end

    context 'when a combined nomenclature goods_nomenclature_item_id' do
      subject(:code) { build(:subheading, :combined_nomenclature_code).code }

      it { is_expected.to eq '01011110' }
    end

    context 'when a taric goods_nomenclature_item_id' do
      subject(:code) { build(:subheading, :taric_code).code }

      it { is_expected.to eq '0101121210' }
    end
  end

  describe '#to_param' do
    subject(:to_param) { build(:subheading).to_param }

    it { is_expected.to eq('0101100000-10') }
  end

  describe '#to_s' do
    context 'when a formatted description is supplied' do
      subject(:description) { build(:subheading, formatted_description: '<strong>Horses</strong>').to_s }

      it { is_expected.to eq('<strong>Horses</strong>') }
    end

    context 'when a formatted description is not supplied' do
      subject(:description) { build(:subheading, formatted_description: nil).to_s }

      it { is_expected.to eq('Horses') }
    end
  end

  describe '#declarable?' do
    subject { heading.declarable? }

    it { is_expected.to be false }
  end
end
