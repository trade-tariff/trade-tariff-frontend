RSpec.describe DutyCalculator::Steps::Vat, :step, :user_session do
  subject(:step) { build(:duty_calculator_vat, user_session:, vat:) }

  let(:vat) { nil }

  let(:user_session) { build(:duty_calculator_user_session, :with_commodity_information) }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(%w[])
    end
  end

  describe '#validations' do
    context 'when vat_code is blank' do
      let(:vat) { nil }

      it { expect(step).not_to be_valid }

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:vat]).to eq(['Select one of the available options'])
      end
    end

    context 'when vat_code is present' do
      let(:vat) { 'VATZ' }

      it { expect(step).to be_valid }

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:vat]).to be_empty
      end
    end
  end

  describe '#save!' do
    let(:vat) { 'VATZ' }

    it 'saves the vat_code to the session' do
      expect { step.save! }.to change(user_session, :vat).from(nil).to('VATZ')
    end
  end

  describe '#vat_options' do
    let(:user_session) { build(:duty_calculator_user_session, commodity_code: '0809400500', commodity_source: 'uk') }

    let(:expected_options) do
      [
        OpenStruct.new(
          id: 'VATR',
          name: 'VAT reduced rate 5% (5.0)',
        ),
        OpenStruct.new(
          id: 'VATZ',
          name: 'VAT zero rate (0.0)',
        ),
        OpenStruct.new(
          id: 'VAT',
          name: 'Value added tax (20.0)',
        ),
      ]
    end

    it 'returns the correct VAT options' do
      expect(step.vat_options).to eq expected_options
    end
  end

  describe '#next_step_path' do
    it 'returns confirm_path' do
      expect(
        step.next_step_path,
      ).to eq(
        confirm_path,
      )
    end
  end

  describe '#previous_step_path' do
    context 'when there are additional codes on the session' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          :with_additional_codes,
        )
      end

      it 'returns additional_codes path with the last measure type id as id' do
        expect(
          step.previous_step_path,
        ).to eq(
          additional_codes_path('103'),
        )
      end
    end

    context 'when there are excise additional codes' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          :with_excise_additional_codes,
        )
      end

      it { expect(step.previous_step_path).to eq(excise_path('DBC')) }
    end

    context 'when there are document codes on the session' do
      let(:user_session) do
        build(
          :duty_calculator_user_session,
          :with_commodity_information,
          :with_document_codes,
        )
      end

      it { expect(step.previous_step_path).to eq(document_codes_path(105)) }
    end

    context 'when there are measure amounts on the session' do
      let(:measure_amount) do
        {
          'dtn' => 1,
        }
      end

      before do
        allow(user_session).to receive(:measure_amount).and_return(measure_amount)
      end

      it 'returns measure_amount_path' do
        expect(
          step.previous_step_path,
        ).to eq(
          measure_amount_path,
        )
      end
    end

    context 'when there are no measure amounts on the session' do
      before do
        allow(user_session).to receive(:measure_amount).and_return({})
      end

      it 'returns measure_amount_path' do
        expect(
          step.previous_step_path,
        ).to eq(
          customs_value_path,
        )
      end
    end
  end
end
