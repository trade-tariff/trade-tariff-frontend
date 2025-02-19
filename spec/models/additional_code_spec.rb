require 'spec_helper'

RSpec.describe AdditionalCode do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[goods_nomenclatures]) }
  end

  describe '#residual?' do
    subject(:abbreviation) { additional_code.residual? }

    context 'when last 2 characters match it returns true' do
      let(:additional_code) { build(:additional_code, code: '1149') }

      it { is_expected.to be(true) }
    end

    context 'when last 2 characters do not match it returns false' do
      let(:additional_code) { build(:additional_code, code: '1111') }

      it { is_expected.to be(false) }
    end
  end

  describe '#pharma?' do
    subject(:additional_code) { build(:additional_code, code:) }

    context 'when code is 2500' do
      let(:code) { '2500' }

      it { is_expected.to be_pharma }
    end

    context 'when code is 2501' do
      let(:code) { '2501' }

      it { is_expected.to be_pharma }
    end

    context 'when code is not a pharma code' do
      let(:code) { '1111' }

      it { is_expected.not_to be_pharma }
    end
  end
end
