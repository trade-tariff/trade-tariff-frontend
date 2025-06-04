RSpec.describe DutyCalculator::Steps::CountryOfOrigin, :step, :user_session do
  subject(:step) do
    build(
      :duty_calculator_country_of_origin,
      user_session:,
      country_of_origin:,
      other_country_of_origin:,
      trade_defence:,
      zero_mfn_duty:,
    )
  end

  let(:user_session) { build(:duty_calculator_user_session, session_attributes) }
  let(:session_attributes) { {} }
  let(:country_of_origin) { '' }
  let(:other_country_of_origin) { '' }
  let(:trade_defence) { '' }
  let(:zero_mfn_duty) { '' }

  describe 'STEPS_TO_REMOVE_FROM_SESSION' do
    it 'returns the correct list of steps' do
      expect(described_class::STEPS_TO_REMOVE_FROM_SESSION).to eq(
        %w[
          trader_scheme
          final_use
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
    context 'when country_of_origin is blank' do
      it { expect(step).not_to be_valid }

      it 'adds the correct validation error message' do
        step.valid?

        expect(step.errors.messages[:country_of_origin]).to eq(['Enter a valid origin for this import'])
      end
    end

    context 'when country_of_origin is present, but not OTHER' do
      let(:country_of_origin) { 'GB' }

      it { expect(step).to be_valid }

      it 'has no validation errors' do
        step.valid?

        expect(step.errors.messages[:country_of_origin]).to be_empty
      end
    end

    context 'when country_of_origin is OTHER' do
      let(:country_of_origin) { 'OTHER' }

      context 'when other_country_of_origin is present' do
        let(:other_country_of_origin) { 'AR' }

        it 'is a valid object' do
          expect(step).to be_valid
        end

        it 'has no validation errors' do
          step.valid?

          expect(step.errors.messages[:country_of_origin]).to be_empty
        end
      end

      context 'when other_country_of_origin is not present' do
        it 'is not a valid object' do
          expect(step).not_to be_valid
        end

        it 'adds the correct validation error message' do
          step.valid?

          expect(step.errors.messages[:country_of_origin]).to eq(['Enter a valid origin for this import'])
        end
      end
    end
  end

  describe '#save!' do
    let(:country_of_origin) { 'GB' }

    it 'saves the country_of_origin to the session' do
      expect { step.save! }.to change(user_session, :country_of_origin).from(nil).to('GB')
    end

    context 'when trade_defence and zero_mfn_duty are passed in as options' do
      let(:trade_defence) { true }
      let(:zero_mfn_duty) { false }

      it 'stores trade_defence on the session' do
        expect { step.save! }.to change(user_session, :trade_defence).from(nil).to(true)
      end

      it 'stores zero_mfn_duty on the session' do
        expect { step.save! }.to change(user_session, :zero_mfn_duty).from(nil).to(false)
      end
    end
  end

  describe '#previous_step_path' do
    it 'returns import_destination_path' do
      expect(
        step.previous_step_path,
      ).to eq(
        import_destination_path,
      )
    end
  end

  describe '#next_step_path' do
    context 'when on NI to GB route' do
      let(:session_attributes) do
        {
          'import_destination' => 'UK',
          'country_of_origin' => 'XI',
        }
      end

      it 'returns duty_path' do
        expect(
          step.next_step_path,
        ).to eq(
          duty_path,
        )
      end
    end

    context 'when on GB to NI route and there is a trade defence in place' do
      let(:trade_defence) { true }

      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
        }
      end

      it 'returns the interstitial_path' do
        expect(
          step.next_step_path,
        ).to eq(
          interstitial_path,
        )
      end
    end

    context 'when on GB to NI route and there is no trade defence in place, but a zero_mfn_duty' do
      let(:trade_defence) { false }
      let(:zero_mfn_duty) { true }

      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
        }
      end

      it 'returns the duty_path' do
        expect(
          step.next_step_path,
        ).to eq(
          duty_path,
        )
      end
    end

    context 'when on GB to NI route and there is no trade defence in place, nor a zero_mfn_duty' do
      let(:trade_defence) { false }
      let(:zero_mfn_duty) { false }

      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
        }
      end

      it 'returns the trader_scheme_path' do
        expect(
          step.next_step_path,
        ).to eq(
          trader_scheme_path,
        )
      end
    end

    context 'when on RoW to GB route' do
      let(:session_attributes) do
        {
          'import_destination' => 'UK',
          'country_of_origin' => 'RO',
        }
      end

      it 'returns the customs_value_path' do
        expect(
          step.next_step_path,
        ).to eq(
          customs_value_path,
        )
      end
    end

    context 'when on RoW to NI route' do
      let(:session_attributes) do
        {
          'import_destination' => 'XI',
          'country_of_origin' => 'OTHER',
          'other_country_of_origin' => 'AR',
          'commodity_source' => 'xi',
        }
      end

      context 'when there is a trade defence in place' do
        let(:trade_defence) { true }

        it 'returns the customs_value_path' do
          expect(
            step.next_step_path,
          ).to eq(
            interstitial_path,
          )
        end
      end

      context 'when there is no trade defence in place' do
        let(:trade_defence) { false }

        context 'when there is a zero mfn duty' do
          let(:zero_mfn_duty) { true }

          it 'returns the customs_value_path' do
            expect(
              step.next_step_path,
            ).to eq(
              customs_value_path,
            )
          end

          it 'sets the commodity source to UK' do
            expect {
              step.next_step_path
            }.to change(user_session, :commodity_source).from('xi').to('uk')
          end
        end

        context 'when there is no zero mfn duty' do
          let(:zero_mfn_duty) { false }

          it 'returns the trader_scheme_path' do
            expect(
              step.next_step_path,
            ).to eq(
              trader_scheme_path,
            )
          end
        end
      end
    end
  end
end
