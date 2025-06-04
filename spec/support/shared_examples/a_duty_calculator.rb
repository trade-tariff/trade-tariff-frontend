RSpec.shared_examples 'a duty calculator' do |config|
  describe '#options' do
    let(:uk_third_country_tariff_option) do
      build(
        :duty_calculator_duty_option_result,
        :third_country_tariff,
        :uk,
        value: 0.2,
      )
    end

    let(:xi_third_country_tariff_option) do
      build(
        :duty_calculator_duty_option_result,
        :third_country_tariff,
        :xi,
        value: 1.2,
      )
    end

    let("uk_#{config[:category]}_option") do
      build(
        :duty_calculator_duty_option_result,
        config[:category],
        :uk,
        value: 100,
      )
    end
    let("xi_#{config[:category]}_option") do
      build(
        :duty_calculator_duty_option_result,
        config[:category],
        :xi,
        value: 101,
      )
    end

    let("xi_cheapest_#{config[:category]}_option") do
      build(
        :duty_calculator_duty_option_result,
        config[:category],
        :xi,
        value: 0.4,
      )
    end

    context 'when there are tariff preferences in both duty calculations' do
      let(:uk_options) do
        DutyCalculator::OptionCollection.new(
          [
            public_send("uk_#{config[:category]}_option"),
            uk_third_country_tariff_option,
          ],
        )
      end
      let(:xi_options) do
        DutyCalculator::OptionCollection.new(
          [
            public_send("xi_#{config[:category]}_option"),
            xi_third_country_tariff_option,
          ],
        )
      end

      it { expect(calculator.options).to be_a(DutyCalculator::OptionCollection) }

      it 'passes the uk preference option and the xi preference option' do
        calculator.options

        expect(DutyCalculator::DutyOptions::Chooser).to have_received(:new).with(public_send("uk_#{config[:category]}_option"), public_send("xi_#{config[:category]}_option"), user_session.total_amount)
      end
    end

    context 'when there is a tariff preference only in the uk duty calculation' do
      let(:uk_options) do
        DutyCalculator::OptionCollection.new(
          [
            public_send("uk_#{config[:category]}_option"),
            uk_third_country_tariff_option,
          ],
        )
      end
      let(:xi_options) do
        DutyCalculator::OptionCollection.new(
          [
            xi_third_country_tariff_option,
          ],
        )
      end

      it { expect(calculator.options).to be_a(DutyCalculator::OptionCollection) }

      it 'passes the uk preference option and the xi mfn option' do
        calculator.options

        expect(DutyCalculator::DutyOptions::Chooser).to have_received(:new).with(
          public_send("uk_#{config[:category]}_option"),
          xi_third_country_tariff_option,
          user_session.total_amount,
        )
      end

      it 'returns the correct options' do
        expect(calculator.options.to_a).to eq([uk_third_country_tariff_option])
      end
    end

    context 'when there is a tariff preference only in the xi duty calculation' do
      let(:uk_options) do
        DutyCalculator::OptionCollection.new(
          [
            uk_third_country_tariff_option,
          ],
        )
      end
      let(:xi_options) do
        DutyCalculator::OptionCollection.new(
          [
            public_send("xi_#{config[:category]}_option"),
            xi_third_country_tariff_option,
          ],
        )
      end

      it { expect(calculator.options).to be_a(DutyCalculator::OptionCollection) }

      it 'returns the correct options' do
        expect(calculator.options.to_a).to eq([uk_third_country_tariff_option, public_send("xi_#{config[:category]}_option")])
      end
    end

    context 'when there are multiple tariff preferences in the both duty calculations' do
      let(:uk_options) do
        DutyCalculator::OptionCollection.new(
          [
            uk_third_country_tariff_option,
            public_send("uk_#{config[:category]}_option"),
            public_send("uk_#{config[:category]}_option"),
          ],
        )
      end
      let(:xi_options) do
        DutyCalculator::OptionCollection.new(
          [
            public_send("xi_#{config[:category]}_option"),
            public_send("xi_cheapest_#{config[:category]}_option"),
            xi_third_country_tariff_option,
          ],
        )
      end

      it { expect(calculator.options).to be_a(DutyCalculator::OptionCollection) }

      it 'returns the correct options' do
        expect(calculator.options.to_a).to eq([uk_third_country_tariff_option, public_send("xi_cheapest_#{config[:category]}_option")])
      end

      it 'passes the uk tariff preferences and the cheapest xi preference' do
        calculator.options

        expect(DutyCalculator::DutyOptions::Chooser).to have_received(:new).with(
          public_send("uk_#{config[:category]}_option"),
          public_send("xi_cheapest_#{config[:category]}_option"),
          user_session.total_amount,
        ).twice
      end
    end

    context 'when there are multiple tariff preferences in the xi duty calculation and none in the uk duty calculation' do
      let(:uk_options) do
        DutyCalculator::OptionCollection.new(
          [
            uk_third_country_tariff_option,
          ],
        )
      end
      let(:xi_options) do
        DutyCalculator::OptionCollection.new(
          [
            xi_third_country_tariff_option,
            public_send("xi_#{config[:category]}_option"),
            public_send("xi_cheapest_#{config[:category]}_option"),
          ],
        )
      end

      it { expect(calculator.options).to be_a(DutyCalculator::OptionCollection) }

      it 'returns the correct options' do
        expect(calculator.options.to_a).to eq(
          [
            uk_third_country_tariff_option,
            public_send("xi_#{config[:category]}_option"),
            public_send("xi_cheapest_#{config[:category]}_option"),
          ],
        )
      end
    end
  end
end
