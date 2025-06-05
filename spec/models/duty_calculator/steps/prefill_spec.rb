RSpec.describe DutyCalculator::Steps::Prefill, :step, :user_session do
  subject(:step) { build(:duty_calculator_prefill) }

  let(:user_session) { build(:duty_calculator_user_session, **session_attributes) }

  describe '#next_step_path' do
    context 'when on NI to GB route' do
      let(:session_attributes) do
        {
          'import_destination' => 'UK',
          'country_of_origin' => 'XI',
        }
      end

      it { expect(step.next_step_path).to eq(duty_path) }
    end

    context 'when on GB to NI route and there is a trade defence in place' do
      let(:session_attributes) do
        {
          'trade_defence' => true,
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
        }
      end

      it { expect(step.next_step_path).to eq(interstitial_path) }
    end

    context 'when on GB to NI route and there is no trade defence in place, but a zero_mfn_duty' do
      let(:session_attributes) do
        {
          'trade_defence' => false,
          'zero_mfn_duty' => true,
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
        }
      end

      it { expect(step.next_step_path).to eq(duty_path) }
    end

    context 'when on GB to NI route and there is no trade defence in place, nor a zero_mfn_duty' do
      let(:session_attributes) do
        {
          'trade_defence' => false,
          'zero_mfn_duty' => false,
          'import_destination' => 'XI',
          'country_of_origin' => 'GB',
        }
      end

      it { expect(step.next_step_path).to eq(trader_scheme_path) }
    end

    context 'when on RoW to GB route' do
      let(:session_attributes) do
        {
          'import_destination' => 'UK',
          'country_of_origin' => 'RO',
        }
      end

      it { expect(step.next_step_path).to eq(customs_value_path) }
    end

    context 'when on RoW to NI route' do
      let(:session_attributes) do
        {
          'trade_defence' => trade_defence,
          'zero_mfn_duty' => zero_mfn_duty,
          'import_destination' => 'XI',
          'country_of_origin' => 'OTHER',
          'other_country_of_origin' => 'AR',
          'commodity_source' => 'xi',
        }
      end
      let(:zero_mfn_duty) { true }

      context 'when there is a trade defence in place' do
        let(:trade_defence) { true }

        it { expect(step.next_step_path).to eq(interstitial_path) }
      end

      context 'when there is no trade defence in place' do
        let(:trade_defence) { false }

        context 'when there is a zero mfn duty' do
          let(:zero_mfn_duty) { true }

          it { expect(step.next_step_path).to eq(customs_value_path) }

          it { expect { step.next_step_path }.to change(user_session, :commodity_source).from('xi').to('uk') }
        end

        context 'when there is no zero mfn duty' do
          let(:zero_mfn_duty) { false }

          it { expect(step.next_step_path).to eq(trader_scheme_path) }
        end
      end
    end
  end
end
