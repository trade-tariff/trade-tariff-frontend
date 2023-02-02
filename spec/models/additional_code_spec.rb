require 'spec_helper'

RSpec.describe AdditionalCode do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[measures]) }
  end

  it_behaves_like 'an entity that has goods nomenclatures' do
    let(:entity) { build(:additional_code, measures:) }
  end

  describe '#residual?' do
    subject(:abbreviation) { additional_code.residual? }

    context 'when last 2 characters match it returns true' do
      let(:additional_code) { build(:additional_code, code: '1149') }

      it { is_expected.to eq(true) }
    end

    context 'when last 2 characters do not match it returns false' do
      let(:additional_code) { build(:additional_code, code: '1111') }

      it { is_expected.to eq(false) }
    end
  end
end
