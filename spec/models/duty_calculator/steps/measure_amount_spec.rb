RSpec.describe DutyCalculator::Steps::MeasureAmount, :step, :user_session do
  subject(:step) do
    build(
      :duty_calculator_measure_amount,
      user_session:,
      measure_amount:,
    )
  end

  let(:user_session) { build(:duty_calculator_user_session, session_attributes) }
  let(:measure_amount) { { 'dtn' => 500.42, 'hlt' => 204.64 } }

  let(:session_attributes) do
    {
      'commodity_code' => '0702000007',
      'commodity_source' => 'uk',
      'referred_service' => 'uk',
      'import_date' => '2022-01-01',
    }
  end

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(%w[additional_code document_code excise])
    end
  end

  describe '#validations' do
    subject(:step) do
      build(
        :duty_calculator_measure_amount,
        user_session:,
        measure_amount:,
        applicable_measure_units: commodity.applicable_measure_units,
      )
    end

    include_context 'with a fake commodity'

    let(:commodity) { build(:duty_calculator_commodity, :with_all_variations_of_measurement_unit) }

    shared_examples_for 'a valid step' do |measure_amount|
      let(:measure_amount) do
        {
          'asv' => 0,
          'brx' => 0,
          'cen' => 1,
          'hlt' => 1,
          'kgm' => 1,
          'spr' => 0,
        }.merge(measure_amount)
      end

      it { expect(step).to be_valid }
    end

    shared_examples_for 'an invalid step' do |measure_amount, error_message|
      let(:measure_amount) { measure_amount }

      before { step.valid? }

      it { expect(step).not_to be_valid }
      it { expect(step.errors.messages[measure_amount.keys.first.to_sym]).to include(error_message) }
    end

    context 'when the answer unit is a percentage abv type' do
      hint = 'Enter the alcohol by volume (ABV) percentage'

      it_behaves_like 'a valid step', { 'asv' => 0 }

      it_behaves_like 'an invalid step', { 'asv' => 'foo' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'asv' => -1 }, "Enter an import quantity value more than or equal too 0. #{hint}"
      it_behaves_like 'an invalid step', { 'asv' => 101 }, "Enter an import quantity value less than or equal too 100. #{hint}"
      it_behaves_like 'an invalid step', { 'asv' => '' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'asv' => nil }, "Enter a numeric import quantity. #{hint}"
    end

    context 'when the answer unit is a percentage type' do
      hint = 'If you do not know the percentage sucrose content (Brix value), check the footnotes for the commodity code to identify how to calculate it.'

      it_behaves_like 'a valid step', { 'brx' => 0 }

      it_behaves_like 'an invalid step', { 'brx' => 'foo' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'brx' => -1 }, "Enter an import quantity value more than or equal too 0. #{hint}"
      it_behaves_like 'an invalid step', { 'brx' => 101 }, "Enter an import quantity value less than or equal too 100. #{hint}"
      it_behaves_like 'an invalid step', { 'brx' => '' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'brx' => nil }, "Enter a numeric import quantity. #{hint}"
    end

    context 'when the answer unit is a number type' do
      hint = 'Enter the number of items'

      it_behaves_like 'a valid step', { 'cen' => 1 }

      it_behaves_like 'an invalid step', { 'cen' => 'foo' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'cen' => 0 }, "Enter an import quantity value greater than zero. #{hint}"
      it_behaves_like 'an invalid step', { 'cen' => '' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'cen' => nil }, "Enter a numeric import quantity. #{hint}"
    end

    context 'when the anser unit is a volume type' do
      hint = 'Enter the value in litres'

      it_behaves_like 'a valid step', { 'hlt' => 1 }

      it_behaves_like 'an invalid step', { 'hlt' => 'foo' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'hlt' => 0 }, "Enter an import quantity value greater than zero. #{hint}"
      it_behaves_like 'an invalid step', { 'hlt' => '' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'hlt' => nil }, "Enter a numeric import quantity. #{hint}"
    end

    context 'when the answer unit is a weight type' do
      hint = 'Enter the value in kilograms'

      it_behaves_like 'a valid step', { 'kgm' => 0.00001 }

      it_behaves_like 'an invalid step', { 'kgm' => 'foo' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'kgm' => 0 }, "Enter an import quantity value greater than zero. #{hint}"
      it_behaves_like 'an invalid step', { 'kgm' => '' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'kgm' => nil }, "Enter a numeric import quantity. #{hint}"
    end

    context 'when the answer unit is a discount type' do
      hint = 'Enter the SPR discount against the full rate, not the chargeable SPR rate. For example, if the full rate, before application of SPR is £10.00 / litre of pure alcohol, and you are entitled to pay £7.00, enter 3.00 as your SPR discount.'

      it_behaves_like 'a valid step', { 'spr' => 0 }

      it_behaves_like 'an invalid step', { 'spr' => 'foo' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'spr' => -1 }, "Enter an import quantity value more than or equal too 0. #{hint}"
      it_behaves_like 'an invalid step', { 'spr' => '' }, "Enter a numeric import quantity. #{hint}"
      it_behaves_like 'an invalid step', { 'spr' => nil }, "Enter a numeric import quantity. #{hint}"
    end
  end

  describe '#save!' do
    it 'saves the measure_amount to the session' do
      step.save!

      expect(user_session.measure_amount.to_unsafe_hash).to eq(measure_amount)
    end
  end

  describe '#previous_step_path' do
    it 'returns customs_value_path' do
      expect(step.previous_step_path).to eq(customs_value_path)
    end
  end

  describe '#next_step_path' do
    let(:applicable_additional_codes) { {} }
    let(:applicable_vat_options) { {} }

    let(:commodity_source) { :uk }
    let(:commodity_code) { '7202118000' }

    let(:filtered_commodity) do
      DutyCalculator::Api::Commodity.build(
        commodity_source,
        commodity_code,
      )
    end

    before do
      allow(DutyCalculator::Api::Commodity).to receive(:build).and_return(filtered_commodity)
      allow(filtered_commodity).to receive_messages(applicable_additional_codes:, applicable_vat_options:)
    end

    context 'when there are applicable additional codes available' do
      let(:applicable_additional_codes) do
        {
          '105' => {
            'additional_codes' => [
              { 'code' => '2600' },
              { 'code' => '2601' },
            ],
          },

          '552' => {
            'additional_codes' => [
              { 'code' => 'B999' },
              { 'code' => 'B349' },
            ],
          },
        }
      end

      it 'redirects to the additional_codes_path of the first measure type id' do
        expect(
          step.next_step_path,
        ).to eq(
          additional_codes_path('105'),
        )
      end
    end

    context 'when there are applicable excise additional codes available' do
      let(:applicable_additional_codes) do
        {
          '306' => {
            'additional_codes' => [
              { 'code' => 'X411' },
              { 'code' => 'X444' },
            ],
          },
        }
      end

      it 'redirects to the additional_codes_path of the first measure type id' do
        expect(step.next_step_path).to eq(excise_path('306'))
      end
    end

    context 'when there are less than 2 applicable vat options' do
      let(:applicable_vat_options) do
        {
          'VATZ' => 'flibble',
        }
      end

      it 'returns confirm_path' do
        expect(step.next_step_path).to eq(confirm_path)
      end
    end

    context 'when there are more than 1 applicable vat options' do
      let(:applicable_vat_options) do
        {
          'VATZ' => 'flibble',
          'VATR' => 'foobar',
        }
      end

      it 'returns vat_path' do
        expect(step.next_step_path).to eq(vat_path)
      end
    end

    it 'returns confirm_path' do
      expect(
        step.next_step_path,
      ).to eq(
        confirm_path,
      )
    end
  end
end
