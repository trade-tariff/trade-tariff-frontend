RSpec.describe DutyCalculator::DutyCalculator, :user_session do
  subject(:calculator) { described_class.new(commodity) }

  let(:user_session) { build(:duty_calculator_user_session, session_attributes) }
  let(:commodity_source) { :uk }
  let(:commodity_code) { '7202118000' }
  let(:session_attributes) do
    {
      'import_date' => '2021-01-01',
      'import_destination' => 'XI',
      'country_of_origin' => 'GB',
      'planned_processing' => 'commercial_purposes',
      'customs_value' => {
        'monetary_value' => '1000',
        'shipping_cost' => '250.89',
        'insurance_cost' => '10',
      },
      'measure_amount' => { 'tnei' => '2' },
      'additional_code' => { 'uk' => { '552' => 'C490' }, 'xi' => {} },
      'commodity_source' => 'uk',
      'commodity_code' => commodity_code,
    }
  end

  let(:commodity) do
    DutyCalculator::Api::Commodity.build(
      commodity_source,
      commodity_code,
    )
  end

  describe '#options' do
    let(:expected_result) do
      [
        {
          type: 'third_country_tariff',
          warning_text: 'Third-country duty will apply as there is no preferential agreement in place for the import of this commodity.',
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,260.89'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Third-country duty (UK)</span>', '2.70% * £1,260.89', '£34.04'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Additional duties (safeguard) (UK)</span>', '25.00% * £1,260.89', '£315.22'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Additional Duties (UK)</span>', '25.00% * £1,260.89', '£315.22'],
            ['Import duty (C490)<br><span class="govuk-green govuk-body-xs"> Definitive anti-dumping duty (UK)</span>', '<span>144.10</span> GBP / <abbr title="Tonne">1000 kg/biodiesel</abbr>', '£288.20'],
            ['VAT <br><span class="govuk-green govuk-body-xs"> Standard rate</span>', '20.00% * £2,213.58', '£442.72'],
            ['<strong>Duty Total</strong>', nil, '<strong>£1,395.40</strong>'],
          ],
          value: 34.04403,
          footnote: I18n.t('measure_type_footnotes.103'),
          measure_sid: 1_881_982,
          source: 'uk',
          category: :third_country_tariff,
          priority: 1,
          scheme_code: nil,
          order_number: nil,
          geographical_area_description: nil,
        },
        {
          type: 'tariff_preference',
          warning_text: nil,
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,260.89'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Tariff preference (UK)</span>', '0.00% * £1,260.89', '£0.00'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Additional duties (safeguard) (UK)</span>', '25.00% * £1,260.89', '£315.22'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Additional Duties (UK)</span>', '25.00% * £1,260.89', '£315.22'],
            ['Import duty (C490)<br><span class="govuk-green govuk-body-xs"> Definitive anti-dumping duty (UK)</span>', '<span>144.10</span> GBP / <abbr title="Tonne">1000 kg/biodiesel</abbr>', '£288.20'],
            ['VAT <br><span class="govuk-green govuk-body-xs"> Standard rate</span>', '20.00% * £2,179.54', '£435.91'],
            ['<strong>Duty Total</strong>', nil, '<strong>£1,354.55</strong>'],
          ],
          value: 0.0,
          geographical_area_description: 'United Kingdom (excluding Northern Ireland)',
          footnote: I18n.t('measure_type_footnotes.142'),
          measure_sid: 3_822_192,
          source: 'uk',
          category: :tariff_preference,
          priority: 2,
          scheme_code: 'albania',
          order_number: nil,
        },
        {
          type: 'non_preferential',
          warning_text: nil,
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,260.89'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Non Preferential Quota (UK)</span>', '20.00% * £1,260.89', '£252.18'],
            # ['Import duty<br><span class="govuk-green govuk-body-xs"> Additional duties (safeguard) (UK)</span>', '25.00% * £1,260.89', '£315.22'], Excluded safeguard
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Additional Duties (UK)</span>', '25.00% * £1,260.89', '£315.22'],
            ['Import duty (C490)<br><span class="govuk-green govuk-body-xs"> Definitive anti-dumping duty (UK)</span>', '<span>144.10</span> GBP / <abbr title="Tonne">1000 kg/biodiesel</abbr>', '£288.20'],
            ['VAT <br><span class="govuk-green govuk-body-xs"> Standard rate</span>', '20.00% * £2,116.49', '£423.30'],
            ['<strong>Duty Total</strong>', nil, '<strong>£1,278.90</strong>'],
          ],
          value: 252.17799999999997,
          footnote: I18n.t('measure_type_footnotes.122'),
          order_number: '054003',
          measure_sid: 20_124_406,
          source: 'uk',
          category: :quota,
          priority: 3,
          scheme_code: nil,
          geographical_area_description: nil,
        },
        {
          type: 'certain_category_goods',
          warning_text: nil,
          values: [
            ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,260.89'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Suspension - goods for certain categories of ships, boats and other vessels and for drilling or production platforms (UK)</span>', '0.00% * £1,260.89', '£0.00'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Additional duties (safeguard) (UK)</span>', '25.00% * £1,260.89', '£315.22'],
            ['Import duty<br><span class="govuk-green govuk-body-xs"> Additional Duties (UK)</span>', '25.00% * £1,260.89', '£315.22'],
            ['Import duty (C490)<br><span class="govuk-green govuk-body-xs"> Definitive anti-dumping duty (UK)</span>', '<span>144.10</span> GBP / <abbr title="Tonne">1000 kg/biodiesel</abbr>', '£288.20'],
            ['VAT <br><span class="govuk-green govuk-body-xs"> Standard rate</span>', '20.00% * £2,179.54', '£435.91'],
            ['<strong>Duty Total</strong>', nil, '<strong>£1,354.55</strong>'],
          ],
          value: 0.0,
          footnote: I18n.t('measure_type_footnotes.117'),
          measure_sid: 20_121_925,
          source: 'uk',
          category: :suspension,
          priority: 3,
          scheme_code: nil,
          order_number: nil,
          geographical_area_description: nil,
        },
        {
          type: 'waiver',
          footnote: "<p class=\"govuk-body\">\n  A claim for a customs duty waiver for duty on goods that would otherwise incur “at risk” tariffs is provided as “de minimis aid”. The maximum allowance for most sectors is €200,000 across a rolling three tax year period. This allowance includes all de minimis aid you have claimed over a 3 tax year period.\n</p> <p class=\"govuk-body\">\n  This type of aid is measured in euros, so it is important to convert any aid received in pound sterling into euros. You can use this <a target=\"_blank\" href=\"https://ec.europa.eu/info/funding-tenders/procedures-guidelines-tenders/information-contractors-and-beneficiaries/exchange-rate-inforeuro_en\" class=\"govuk-link\">exchange rate tool</a> to calculate the applicable euro equivalent of the value of the aid for the month you were awarded the aid.\n</p>",
          warning_text: nil,
          value: nil,
          values: nil,
          source: nil,
          measure_sid: nil,
          category: :waiver,
          priority: 10,
          scheme_code: nil,
          order_number: nil,
          geographical_area_description: nil,
        },
      ]
    end

    it { expect(calculator.options).to be_a(DutyCalculator::OptionCollection) }

    it 'returns the correct duty options' do
      result = calculator.options.to_a.map do |option_result|
        option_result.attributes.deep_symbolize_keys
      end

      expect(result).to eq(expected_result)
    end
  end
end
