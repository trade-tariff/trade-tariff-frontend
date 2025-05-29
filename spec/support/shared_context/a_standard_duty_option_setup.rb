RSpec.shared_context 'with a standard duty option setup' do |option_type|
  subject(:service) { described_class.new(measure, [], nil) }

  let(:measure) { build(:measure, option_type) }
  let(:evaluator) { instance_double(ExpressionEvaluators::AdValorem, call: duty_evaluation) }
  let(:duty_evaluation) do
    {
      calculation: '8.00% * £1200.00',
      formatted_value: '£96.00',
      value: 96,
    }
  end

  let(:user_session) do
    build(
      :user_session,
      :with_commodity_information,
      :with_customs_value,
      :with_excise_additional_codes,
    )
  end

  before do
    allow(measure).to receive(:evaluator).and_return(evaluator)
  end
end
