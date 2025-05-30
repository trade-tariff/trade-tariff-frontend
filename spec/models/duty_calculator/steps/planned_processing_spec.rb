RSpec.describe DutyCalculator::Steps::PlannedProcessing, :step, :user_session do
  subject(:step) { build(:duty_calculator_planned_processing, user_session:, planned_processing:) }

  let(:session_attributes) { {} }
  let(:user_session) { build(:duty_calculator_user_session, session_attributes) }
  let(:planned_processing) { '' }

  describe '#validations' do
    context 'when planned processing answer is blank' do
      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:planned_processing]).to eq(['Select one of the available options'])
      end
    end

    context 'when planned processing answer is present' do
      let(:planned_processing) { 'without_any_processing' }

      it 'is a valid object' do
        expect(step).to be_valid
      end

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:planned_processing]).to be_empty
      end
    end
  end

  describe '#save!' do
    let(:planned_processing) { 'without_any_processing' }

    it 'saves the planned_processing to the session' do
      expect { step.save! }.to change(user_session, :planned_processing).from(nil).to('without_any_processing')
    end
  end

  describe '#next_step_path' do
    let(:answer) { 'without_any_processing' }
    let(:session_attributes) do
      {
        'import_destination' => 'XI',
        'country_of_origin' => 'GB',
        'planned_processing' => answer,
      }
    end

    context 'when on GB to NI route' do
      context 'when the answer is not commercial_purposes' do
        let(:answer) { 'without_any_processing' }

        it { expect(step.next_step_path).to eq(duty_path) }
      end

      context 'when the answer is commercial_purposes' do
        let(:answer) { 'commercial_purposes' }

        it { expect(step.next_step_path).to eq(certificate_of_origin_path) }
      end
    end

    context 'when on RoW to NI route' do
      shared_examples_for 'a step with a next step as customs_value' do |answer, meursing_trait|
        let(:user_session) { build(:duty_calculator_user_session, meursing_trait, :with_row_to_ni_route, planned_processing: answer) }

        it { expect(step.next_step_path).to eq(customs_value_path) }
      end

      shared_examples_for 'a step with a next step as meursing_additional_codes' do |answer, meursing_trait|
        let(:user_session) { build(:duty_calculator_user_session, meursing_trait, :with_row_to_ni_route, planned_processing: answer) }

        it { expect(step.next_step_path).to eq(meursing_additional_codes_path) }
      end

      it_behaves_like 'a step with a next step as customs_value', 'commercial_processing', :with_non_meursing_commodity
      it_behaves_like 'a step with a next step as customs_value', 'without_any_processing', :with_non_meursing_commodity

      it_behaves_like 'a step with a next step as meursing_additional_codes', 'commercial_processing', :with_meursing_commodity
      it_behaves_like 'a step with a next step as meursing_additional_codes', 'without_any_processing', :with_meursing_commodity

      context 'when the answer is commercial_purposes' do
        let(:user_session) { build(:duty_calculator_user_session, planned_processing: 'commercial_purposes') }

        it { expect(step.next_step_path).to eq(interstitial_path) }
      end
    end
  end

  describe '#previous_step_path' do
    let(:session_attributes) do
      {
        'import_destination' => 'XI',
        'country_of_origin' => 'GB',
        'trader_scheme' => 'yes',
      }
    end

    it { expect(step.previous_step_path).to eq(annual_turnover_path) }
  end
end
