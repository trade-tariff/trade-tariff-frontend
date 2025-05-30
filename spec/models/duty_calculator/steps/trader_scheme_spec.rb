RSpec.describe DutyCalculator::Steps::TraderScheme, :step, :user_session do
  subject(:step) { build(:duty_calculator_trader_scheme, user_session:, trader_scheme:) }

  let(:user_session) { build(:duty_calculator_user_session, session_attributes) }
  let(:session_attributes) { {} }
  let(:trader_scheme) { '' }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(
        %w[
          final_use
          certificate_of_origin
          planned_processing
          document_code
          excise
        ],
      )
    end
  end

  describe '#validations' do
    context 'when trader scheme answer is blank' do
      it 'is not a valid object' do
        expect(step).not_to be_valid
      end

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:trader_scheme]).to eq(['Select one of the two options'])
      end
    end

    context 'when trader scheme answer is present' do
      let(:trader_scheme) { 'no' }

      it 'is a valid object' do
        expect(step).to be_valid
      end

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:trader_scheme]).to be_empty
      end
    end
  end

  describe '#save!' do
    let(:trader_scheme) { 'yes' }

    it 'saves the trader_scheme to the session' do
      expect { step.save! }.to change(user_session, :trader_scheme).from(nil).to('yes')
    end
  end

  describe '#next_step_path' do
    let(:answer) { 'yes' }
    let(:session_attributes) do
      {
        'import_destination' => 'XI',
        'country_of_origin' => 'GB',
        'trader_scheme' => answer,
      }
    end

    context 'when on GB to NI route and answer is yes' do
      it 'returns country_of_origin_path' do
        expect(
          step.next_step_path,
        ).to eq(
          final_use_path,
        )
      end
    end

    context 'when on GB to NI route and answer is no' do
      let(:answer) { 'no' }

      it 'returns country_of_origin_path' do
        expect(
          step.next_step_path,
        ).to eq(
          certificate_of_origin_path,
        )
      end
    end

    context 'when on RoW to NI route and answer is no' do
      let(:answer) { 'no' }

      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'OTHER',
          'other_country_of_origin' => 'AR',
          'trader_scheme' => answer,
        }
      end

      it 'returns interstitial_path' do
        expect(
          step.next_step_path,
        ).to eq(
          interstitial_path,
        )
      end
    end
  end

  describe '#previous_step_path' do
    let(:session_attributes) do
      {
        'import_destination' => 'XI',
        'country_of_origin' => 'GB',
      }
    end

    context 'when on GB to NI route' do
      it 'returns country_of_origin_path' do
        expect(
          step.previous_step_path,
        ).to eq(
          country_of_origin_path,
        )
      end
    end

    context 'when on RoW to NI route' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'OTHER',
          'other_country_of_origin' => 'AR',
        }
      end

      it 'returns country_of_origin_path' do
        expect(
          step.previous_step_path,
        ).to eq(
          country_of_origin_path,
        )
      end
    end
  end
end
