RSpec.describe DutyOptions::Base, :user_session do
  subject(:service) { described_class.new(measure, additional_duty_options, vat_measure) }

  let(:measure) { build(:measure, :third_country_tariff) }
  let(:evaluator) { instance_double(ExpressionEvaluators::AdValorem, call: duty_evaluation) }
  let(:duty_evaluation) do
    {
      calculation: '8.00% * £1200.00',
      formatted_value: '£96.00',
      value: 96,
    }
  end

  let(:additional_duty_options) { [build(:duty_option_result, :additional_duty)] }

  let(:vat_measure) { build(:measure, :vat) }
  let(:vat_evaluator) do
    instance_double(
      ExpressionEvaluators::Vat,
      call: vat_evaluation,
    )
  end
  let(:vat_evaluation) do
    {
      calculation: '20.00% * £1200.00',
      formatted_value: '£240',
      value: 240,
    }
  end

  let(:user_session) { build(:user_session, :with_commodity_information, :with_customs_value) }

  before do
    allow(measure).to receive(:evaluator).and_return(evaluator)
    allow(ExpressionEvaluators::Vat).to receive(:new).and_return(vat_evaluator)
  end

  describe '#call' do
    let(:default_expected_option) do
      {
        type: 'base',
        footnote: "<p class=\"govuk-body\">\n  A ‘Third country’ duty is the tariff charged where there isn’t a trade agreement or a customs union available. It can also be referred to as the Most Favoured Nation (<abbr title=\"Most Favoured Nation\">MFN</abbr>) rate.\n</p>",
        warning_text: nil,
        measure_sid: measure.id,
        source: 'uk',
        category: :default,
        priority: 5,
        order_number: nil,
        geographical_area_description: nil,
        scheme_code: nil,
      }
    end

    context 'when the measure is a simple ad valorem measure' do
      let(:evaluator) { instance_double(ExpressionEvaluators::AdValorem, call: duty_evaluation) }

      let(:duty_evaluation) do
        {
          calculation: '8.00% * £1200.00',
          formatted_value: '£96.00',
          value: 96,
        }
      end

      let(:expected_option) do
        default_expected_option.merge(
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,200.00'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Please implement a concrete option class (UK)</span>', '8.00% * £1200.00', '£96.00'],
            ['Excise<br><span class="govuk-green govuk-body-xs">990 - Climate Change Levy (Tax code 990): solid fuels (coal and lignite, coke and semi-coke of coal or lignite, and petroleum coke)</span>', '25.00% * £1,200.00', '£300.00'],
            ['VAT <br><span class="govuk-green govuk-body-xs"> Standard rate</span>', '20.00% * £1200.00', '£240'],
            ['<strong>Duty Total</strong>', nil, '<strong>£636.00</strong>'],
          ],
          value: 96,
        )
      end

      it { expect(service.call.attributes.deep_symbolize_keys).to eq(expected_option) }
    end

    context 'when the measure is a simple measure unit measure' do
      let(:evaluator) { instance_double(ExpressionEvaluators::MeasureUnit, call: duty_evaluation) }

      let(:duty_evaluation) do
        {
          calculation: '35.10 EUR / 100 kg * 120.00',
          value: 3610.1052,
          formatted_value: '£3,610.11',
          total_quantity: 120.0,
          unit: 'x 100 kg',
        }
      end

      let(:expected_option) do
        default_expected_option.merge(
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,200.00'],
            ['Import quantity', nil, '120.00 x 100 kg'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Please implement a concrete option class (UK)</span>', '35.10 EUR / 100 kg * 120.00', '£3,610.11'],
            ['Excise<br><span class="govuk-green govuk-body-xs">990 - Climate Change Levy (Tax code 990): solid fuels (coal and lignite, coke and semi-coke of coal or lignite, and petroleum coke)</span>', '25.00% * £1,200.00', '£300.00'],
            ['VAT <br><span class="govuk-green govuk-body-xs"> Standard rate</span>', '20.00% * £1200.00', '£240'],
            ['<strong>Duty Total</strong>', nil, '<strong>£4,150.11</strong>'],
          ],
          value: 3610.1052,
        )
      end

      it { expect(service.call.attributes.deep_symbolize_keys).to eq(expected_option) }
    end

    context 'when the measure is a compound measure' do
      let(:evaluator) { instance_double(ExpressionEvaluators::Compound, call: duty_evaluation) }

      let(:duty_evaluation) do
        {
          value: 97.0,
          formatted_value: '£97.00',
          calculation: '6.00 % + 25.00 GBP / 100 kg MAX 6.00 %',
        }
      end

      let(:expected_option) do
        default_expected_option.merge(
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,200.00'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Please implement a concrete option class (UK)</span>', '6.00 % + 25.00 GBP / 100 kg MAX 6.00 %', '£97.00'],
            ['Excise<br><span class="govuk-green govuk-body-xs">990 - Climate Change Levy (Tax code 990): solid fuels (coal and lignite, coke and semi-coke of coal or lignite, and petroleum coke)</span>', '25.00% * £1,200.00', '£300.00'],
            ['VAT <br><span class="govuk-green govuk-body-xs"> Standard rate</span>', '20.00% * £1200.00', '£240'],
            ['<strong>Duty Total</strong>', nil, '<strong>£637.00</strong>'],
          ],
          value: 97.0,
        )
      end

      it { expect(service.call.attributes.deep_symbolize_keys).to eq(expected_option) }
    end

    context 'when no vat measure is passed' do
      let(:vat_measure) {}

      let(:expected_option) do
        default_expected_option.merge(
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,200.00'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Please implement a concrete option class (UK)</span>', '8.00% * £1200.00', '£96.00'],
            ['Excise<br><span class="govuk-green govuk-body-xs">990 - Climate Change Levy (Tax code 990): solid fuels (coal and lignite, coke and semi-coke of coal or lignite, and petroleum coke)</span>', '25.00% * £1,200.00', '£300.00'],
            ['<strong>Duty Total</strong>', nil, '<strong>£396.00</strong>'],
          ],
          value: 96,
        )
      end

      it { expect(service.call.attributes.deep_symbolize_keys).to eq(expected_option) }
    end

    context 'when no additional duty options are passsed' do
      let(:additional_duty_options) { [] }

      let(:expected_option) do
        default_expected_option.merge(
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,200.00'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Please implement a concrete option class (UK)</span>', '8.00% * £1200.00', '£96.00'],
            ['VAT <br><span class="govuk-green govuk-body-xs"> Standard rate</span>', '20.00% * £1200.00', '£240'],
            ['<strong>Duty Total</strong>', nil, '<strong>£336.00</strong>'],
          ],
          value: 96,
        )
      end

      it { expect(service.call.attributes.deep_symbolize_keys).to eq(expected_option) }
    end
  end
end
