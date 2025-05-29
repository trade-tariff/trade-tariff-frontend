RSpec.describe DutyCalculator::Api::MeasureComponent do
  subject(:component) { described_class.new }

  it { is_expected.to be_a(DutyCalculator::Api::BaseComponent) }
  it { is_expected.not_to be_belongs_to_measure_condition }
end
