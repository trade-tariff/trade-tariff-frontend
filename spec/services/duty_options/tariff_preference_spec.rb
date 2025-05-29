RSpec.describe DutyOptions::TariffPreference, :user_session do
  include_context 'with a standard duty option setup', :tariff_preference

  describe '#call' do
    let(:expected_table) do
      {
        footnote: "<p class=\"govuk-body\">\n  A tariff preference is the rate available if a free trade agreement or another arrangement is in place between the UK and an overseas country. Goods will need to comply with the <a target=\"_blank\" href=\"https://www.gov.uk/guidance/check-your-goods-meet-the-rules-of-origin\" class=\"govuk-link\">rules of origin</a> to benefit from this rate and you will need to provide evidence of compliance with your shipment.\n</p>",
        warning_text: nil,
        values: [
          ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,200.00'],
          ['Import duty<br><span class="govuk-green govuk-body-xs"> Tariff preference (UK)</span>', '8.00% * £1200.00', '£96.00'],
          ['<strong>Duty Total</strong>', nil, '<strong>£96.00</strong>'],
        ],
        value: 96,
        measure_sid: measure.id,
        source: 'uk',
        type: 'tariff_preference',
        category: :tariff_preference,
        priority: 2,
        scheme_code: 'eu',
        order_number: nil,
        geographical_area_description: 'United Kingdom',
      }
    end

    it { expect(service.call.attributes.deep_symbolize_keys).to eq(expected_table) }
  end
end
