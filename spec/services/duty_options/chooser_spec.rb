RSpec.describe DutyOptions::Chooser do
  subject(:service) { described_class.new(uk_option, xi_option, 100) }

  describe '#call' do
    context 'when the delta is less than 3 percent of the customs_value' do
      let(:uk_option) { build(:duty_option_result, value: 3.0) }
      let(:xi_option) { build(:duty_option_result, value: 4.0) } # 1 % delta

      it { expect(service.call).to eq(uk_option) }
    end

    context 'when the delta is equal to 3 percent of the customs_value' do
      let(:uk_option) { build(:duty_option_result, value: 3.0) }
      let(:xi_option) { build(:duty_option_result, value: 6.0) } # 3 % delta

      it { expect(service.call).to eq(uk_option) }
    end

    context 'when the delta is more than 3 percent of the customs_value' do
      let(:uk_option) { build(:duty_option_result, value: 3.0) }
      let(:xi_option) { build(:duty_option_result, value: 7.0) } # 4 % delta

      it { expect(service.call).to eq(xi_option) }
    end
  end
end
