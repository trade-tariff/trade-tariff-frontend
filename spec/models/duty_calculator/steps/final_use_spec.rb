RSpec.describe DutyCalculator::Steps::FinalUse, :step, :user_session do
  subject(:step) { build(:duty_calculator_final_use, user_session:, final_use:) }

  let(:session_attributes) { {} }
  let(:user_session) { build(:duty_calculator_user_session, session_attributes) }
  let(:final_use) { '' }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(
        %w[
          certificate_of_origin
          annual_turnover
          planned_processing
          document_code
          excise
        ],
      )
    end
  end

  describe '#validations' do
    context 'when final use answer is blank' do
      it { expect(step).not_to be_valid }

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:final_use]).to eq(['Select one of the two options'])
      end
    end

    context 'when final use answer is present' do
      let(:final_use) { 'no' }

      it 'is a valid object' do
        expect(step).to be_valid
      end

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:final_use]).to be_empty
      end
    end
  end

  describe '#save!' do
    let(:final_use) { 'yes' }

    it 'saves the trader_scheme to the session' do
      expect { step.save! }.to change(user_session, :final_use).from(nil).to('yes')
    end
  end

  describe '#heading' do
    context 'when on GB to NI route' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
        }
      end

      it 'returns the correct heading' do
        expect(step.heading).to eq('Are your goods for sale to, or final use by, end-consumers located in the United Kingdom?')
      end
    end

    context 'when on RoW to NI' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'OTHER',
          'other_country_of_origin' => 'AR',
        }
      end

      it 'returns the correct heading' do
        expect(step.heading).to eq('Are your goods for sale to, or final use by, end-consumers located in Northern Ireland?')
      end
    end
  end

  describe '#options' do
    let(:expected) do
      [
        OpenStruct.new(id: 'yes', name: I18n.t("final_use.#{locale_key}.yes_option")),
        OpenStruct.new(id: 'no', name: I18n.t("final_use.#{locale_key}.no_option")),
      ]
    end

    let(:locale_key) { 'gb_to_ni' }

    context 'when on GB to NI route' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
        }
      end

      it 'returns the correct heading' do
        expect(step.options).to eq(expected)
      end
    end

    context 'when on RoW to NI' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'OTHER',
          'other_country_of_origin' => 'AR',
        }
      end

      let(:locale_key) { 'row_to_ni' }

      it 'returns the correct heading' do
        expect(step.options).to eq(expected)
      end
    end
  end

  describe '#next_step_path' do
    context 'when on GB to NI route and final use answer is yes' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
          'final_use' => 'yes',
        }
      end

      it { expect(step.next_step_path).to eq(annual_turnover_path) }
    end

    context 'when on GB to NI route and final use answer is no' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
          'final_use' => 'no',
        }
      end

      it { expect(step.next_step_path).to eq(certificate_of_origin_path) }
    end

    context 'when on RoW to NI route and final use answer is no' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'OTHER',
          'other_country_of_origin' => 'AR',
          'final_use' => 'no',
        }
      end

      it { expect(step.next_step_path).to eq(interstitial_path) }
    end
  end

  describe '#previous_step_path' do
    context 'when on GB to NI route' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
          'trader_scheme' => 'yes',
        }
      end

      it { expect(step.previous_step_path).to eq(trader_scheme_path) }
    end

    context 'when on RoW to NI route' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'OTHER',
          'other_country_of_origin' => 'AR',
        }
      end

      it { expect(step.previous_step_path).to eq(trader_scheme_path) }
    end
  end
end
