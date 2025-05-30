RSpec.describe DutyCalculator::OptionCollection do
  subject(:collection) { described_class.new(options) }

  let(:options) do
    [
      third_country_tariff_option,
      tariff_preference_option,
      cheapest_tariff_preference_option,
      suspension_option,
      cheapest_suspension_option,
      quota_option,
      cheapest_quota_option,
    ]
  end

  let(:third_country_tariff_option) do
    build(
      :duty_calculator_duty_option_result,
      :third_country_tariff,
      value: 0.2,
    )
  end
  let(:tariff_preference_option) do
    build(
      :duty_calculator_duty_option_result,
      :tariff_preference,
      value: 100,
    )
  end
  let(:cheapest_tariff_preference_option) do
    build(
      :duty_calculator_duty_option_result,
      :tariff_preference,
      value: 0.5,
    )
  end
  let(:suspension_option) do
    build(
      :duty_calculator_duty_option_result,
      :suspension,
      value: 100,
    )
  end
  let(:cheapest_suspension_option) do
    build(
      :duty_calculator_duty_option_result,
      :suspension,
      value: 0.5,
    )
  end
  let(:quota_option) do
    build(
      :duty_calculator_duty_option_result,
      :quota,
      value: 100,
    )
  end
  let(:cheapest_quota_option) do
    build(
      :duty_calculator_duty_option_result,
      :quota,
      value: 0.5,
    )
  end

  describe '#tariff_preference_options' do
    it { expect(collection.tariff_preference_options).to eq([tariff_preference_option, cheapest_tariff_preference_option]) }
  end

  describe '#third_country_tariff_options' do
    it { expect(collection.third_country_tariff_options).to eq([third_country_tariff_option]) }
  end

  describe '#suspension_options' do
    it { expect(collection.suspension_options).to eq([suspension_option, cheapest_suspension_option]) }
  end

  describe '#quota_options' do
    it { expect(collection.quota_options).to eq([quota_option, cheapest_quota_option]) }
  end

  describe '#cheapest_tariff_preference_option' do
    it { expect(collection.cheapest_tariff_preference_option).to eq(cheapest_tariff_preference_option) }
  end

  describe '#cheapest_suspension_option' do
    it { expect(collection.cheapest_suspension_option).to eq(cheapest_suspension_option) }
  end

  describe '#third_country_tariff_option' do
    it { expect(collection.third_country_tariff_option).to eq(third_country_tariff_option) }
  end

  describe '#cheapest_quota_option' do
    it { expect(collection.cheapest_quota_option).to eq(cheapest_quota_option) }
  end

  describe '#size' do
    it { expect(collection.size).to eq(options.size) }
  end

  shared_examples_for 'a wrapped option collection method' do |method|
    subject(:collection) { described_class.new([]) }

    it { expect(collection.public_send(method, &:foo)).to be_a(described_class) }
  end

  it_behaves_like 'a wrapped option collection method', :reject
  it_behaves_like 'a wrapped option collection method', :select
  it_behaves_like 'a wrapped option collection method', :sort_by
  it_behaves_like 'a wrapped option collection method', :uniq
end
