require 'spec_helper'

RSpec.describe Heading do
  subject(:heading) { build(:heading) }

  describe '.relationships' do
    let(:expected_relationships) do
      %i[
        ancestors
        chapter
        children
        commodities
        export_measures
        footnotes
        import_measures
        import_trade_summary
        section
      ]
    end

    it { expect(described_class.relationships).to match_array(expected_relationships) }
  end

  it_behaves_like 'a declarable' do
    subject(:declarable) { build(:heading, import_measures: measures, footnotes:) }

    let(:footnotes) { [] }
  end

  describe '#heading' do
    it { expect(heading.heading).to eq heading }
  end

  describe '#to_param' do
    it { expect(heading.to_param).to eq heading.short_code }
  end

  describe '#commodity_code' do
    it { expect(heading.commodity_code).to eq(heading.code) }
  end

  describe '#consigned?' do
    it { is_expected.not_to be_consigned }
  end

  describe '#heading?' do
    it { is_expected.to be_heading }
  end

  describe '#calculate_duties?' do
    it { is_expected.not_to be_calculate_duties }
  end

  describe '#rules' do
    subject(:rules) { heading.rules_of_origin('FR') }

    before { allow(RulesOfOrigin::Scheme).to receive(:for_heading_and_country).and_return([]) }

    context 'with declarable heading instance' do
      before { heading.declarable = true }

      it { is_expected.to be_instance_of Array }
    end

    context 'with non declarable heading instance' do
      before { heading.declarable = false }

      it { is_expected.to be_nil }
    end
  end

  describe '#has_safeguarding_measure?' do
    subject { build :heading, import_measures: [vat, measure] }

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
end
