RSpec.describe DutyCalculator::Api::AdditionalCode do
  subject(:additional_code) { build(:duty_calculator_additional_code, :company) }

  it_behaves_like 'a resource that has attributes',
                  id: 'flibble',
                  code: 'C490',
                  description: 'COFCO International Argentina S.A.',
                  formatted_description: 'COFCO International Argentina S.A.'

  describe '#excise?' do
    context 'when the additional code type is `excise`' do
      subject(:additional_code) { build(:duty_calculator_additional_code, :excise) }

      it { is_expected.to be_excise }
    end

    context 'when the additional code type is not `excise`' do
      subject(:additional_code) { build(:duty_calculator_additional_code, :company) }

      it { is_expected.not_to be_excise }
    end
  end

  describe '#additional_code_type' do
    it { expect(additional_code.additional_code_type).to eq('C') }
  end

  describe '#additional_code_id' do
    it { expect(additional_code.additional_code_id).to eq('490') }
  end

  describe '#formatted_additional_code' do
    context 'when the additional code type is `excise`' do
      subject(:additional_code) { build(:duty_calculator_additional_code, :excise) }

      it { expect(additional_code.formatted_code).to eq('99A') }
    end

    context 'when the additional code type is not `excise`' do
      subject(:additional_code) { build(:duty_calculator_additional_code, :company) }

      it { expect(additional_code.formatted_code).to eq('C490') }
    end
  end
end
