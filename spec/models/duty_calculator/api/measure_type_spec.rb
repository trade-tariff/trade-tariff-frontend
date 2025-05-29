RSpec.describe DutyCalculator::Api::MeasureType do
  it_behaves_like 'a resource that has attributes',
                  id: '360',
                  description: 'Phytosanitary Certificate (import)',
                  national: nil,
                  measure_type_series_id: 'B'

  it_behaves_like 'a resource that has an enum', :measure_type_series_id, {
    applicable_duty: %w[C],
    anti_dumping_and_countervailing_duty: %w[D],
    additional_duty: %w[F],
    countervailing_charge_duty: %w[J],
    unit_price_duty: %w[M],
    excise: %w[Q],
  }

  describe '#call' do
    subject(:measure_type) { described_class.new(id:) }

    context 'when there is a corresponding option for the id' do
      let(:id) { '142' }

      it { expect(measure_type.option).to eq(DutyCalculator::DutyOptions::TariffPreference) }
    end

    context 'when there is not a corresponding option' do
      let(:id) { '999' }

      it { expect(measure_type.option).to be_nil }
    end
  end

  describe '#additional_duty_option' do
    subject(:measure_type) { described_class.new(id:) }

    context 'when there is a corresponding option for the id' do
      let(:id) { '551' }

      it { expect(measure_type.additional_duty_option).to eq(DutyCalculator::DutyOptions::AdditionalDuty::ProvisionalAntiDumping) }
    end

    context 'when there is not a corresponding option' do
      let(:id) { '999' }

      it { expect(measure_type.additional_duty_option).to be_nil }
    end
  end

  describe '.supported_option_category?' do
    context 'when there is a corresponding option for the category' do
      let(:category) { :quota }

      it { expect(described_class.supported_option_category?(category)).to be true }
    end

    context 'when there is not a corresponding option for the category' do
      let(:category) { :flibble }

      it { expect(described_class.supported_option_category?(category)).to be false }
    end
  end
end
