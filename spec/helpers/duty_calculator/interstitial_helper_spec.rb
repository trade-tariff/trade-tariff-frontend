RSpec.describe DutyCalculator::InterstitialHelper, :user_session do
  describe '#interstitial_partial_options' do
    subject(:partial_options) { helper.interstitial_partial_options }

    context 'when on no particular route' do
      let(:user_session) { build(:duty_calculator_user_session) }

      it 'returns fallback partial options' do
        expected_options = {
          locals: {
            body: 'Please give feedback <a class="govuk-link" target="_blank" rel="noopener" href="http://test.host/feedback">here</a>',
            heading: 'Oops. You were not meant to get here',
          },
          partial: 'duty_calculator/steps/interstitial/shared/context',
        }

        expect(partial_options).to eq(expected_options)
      end
    end

    context 'when on a gb to ni route with a trade defence in place' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :with_trade_defence) }

      it 'returns correct partial options' do
        expected_options = {
          locals: {
            body: "As this commodity attracts a trade defence measure, imports of this commodity are treated as 'at risk' under all circumstances.",
            heading: 'EU duties apply to this import',
          },
          partial: 'duty_calculator/steps/interstitial/shared/context',
        }

        expect(partial_options).to eq(expected_options)
      end
    end

    context 'when on a gb to ni route without proof of origin' do
      let(:user_session) { build(:duty_calculator_user_session, :with_gb_to_ni_route, :without_certificate_of_origin) }

      it 'returns correct partial options' do
        expected_options = {
          locals: {
            body: 'As you have no valid proof of origin, imports of this commodity are subject to EU import duties.',
            heading: 'EU duties apply to this import',
          },
          partial: 'duty_calculator/steps/interstitial/shared/context',
        }

        expect(partial_options).to eq(expected_options)
      end
    end

    context 'when on a row to ni route with a trade defence in place' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_trade_defence) }

      it 'returns correct partial options' do
        expected_options = {
          locals: {
            heading: 'EU duties apply to this import',
            body: "As this commodity attracts a trade defence measure, imports of this commodity are treated as 'at risk'.",
          },
          partial: 'duty_calculator/steps/interstitial/shared/context',
        }

        expect(partial_options).to eq(expected_options)
      end
    end

    context 'when on a row to ni route and not on the trusted trader scheme' do
      let(:user_session) { build(:duty_calculator_user_session, :with_import_date, :with_row_to_ni_route, :without_trader_scheme) }

      it 'returns correct partial options' do
        expected_options = {
          locals: {
            body: "As you are not authorised under the UK Internal Market Scheme, imports of this commodity are treated as 'at risk'. <a href='https://www.gov.uk/guidance/apply-for-authorisation-for-the-uk-trader-scheme-if-you-bring-goods-into-northern-ireland' class='govuk-link' target='_blank'>Find out more about applying for authorisation for the UK Internal Market Scheme</a>.",
            heading: 'EU duties apply to this import',
          },
          partial: 'duty_calculator/steps/interstitial/shared/context',
        }

        expect(partial_options).to eq(expected_options)
      end
    end

    context 'when on a row to ni route and not for final use in ni' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :without_final_use) }

      it 'returns correct partial options' do
        expected_options = {
          locals: {
            body: "As your goods are not for final use in Northern Ireland, imports of this commodity are treated as 'at risk'.",
            heading: 'EU duties apply to this import',
          },
          partial: 'duty_calculator/steps/interstitial/shared/context',
        }

        expect(partial_options).to eq(expected_options)
      end
    end

    context 'when on a row to ni route and further processing is unacceptable' do
      let(:user_session) { build(:duty_calculator_user_session, :with_row_to_ni_route, :with_unacceptable_processing) }

      it 'returns correct partial options' do
        expected_options = {
          locals: {
            body: "As your goods are subject to commercial processing, imports of this commodity are treated as 'at risk'.",
            heading: 'EU duties apply to this import',
          },
          partial: 'duty_calculator/steps/interstitial/shared/context',
        }

        expect(partial_options).to eq(expected_options)
      end
    end
  end
end
