RSpec.describe DutyCalculator::RowToNiDutyCalculator, :user_session do
  subject(:calculator) { described_class.new(uk_options, xi_options) }

  let(:user_session) do
    build(
      :duty_calculator_user_session,
      :with_commodity_information,
      :with_import_date,
      :with_import_destination,
      :with_country_of_origin,
      :without_trader_scheme,
      :with_certificate_of_origin,
      :with_customs_value,
      :with_measure_amount,
      :with_vat,
    )
  end

  before do
    allow(DutyCalculator::DutyOptions::Chooser).to receive(:new).and_call_original
  end

  it_behaves_like 'a duty calculator', category: :tariff_preference
  it_behaves_like 'a duty calculator', category: :suspension
  it_behaves_like 'a duty calculator', category: :quota

  describe '#call' do
    let(:unhandled_option) do
      build(
        :duty_calculator_duty_option_result,
        :unhandled,
      )
    end

    context 'when there are unhandled options' do
      let(:uk_options) do
        DutyCalculator::OptionCollection.new(
          [
            unhandled_option,
          ],
        )
      end
      let(:xi_options) do
        DutyCalculator::OptionCollection.new(
          [
            unhandled_option,
          ],
        )
      end

      it { expect { calculator.options }.to raise_error(I18n::MissingTranslationData) }
    end
  end
end
