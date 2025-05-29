RSpec.describe DutyOptions::Suspension::Preferential, :user_session do
  include_context 'with a standard duty option setup', :preferential_suspension

  describe '#call' do
    let(:expected_table) do
      {
        footnote: I18n.t('measure_type_footnotes.141'),
        warning_text: nil,
        values: [
          ['Valuation for import', 'Value of goods + freight + insurance costs', '£1,200.00'],
          ['Import duty<br><span class="govuk-green govuk-body-xs"> Preferential Suspension (UK)</span>', '8.00% * £1200.00', '£96.00'],
          ['<strong>Duty Total</strong>', nil, '<strong>£96.00</strong>'],
        ],
        value: 96,
        measure_sid: measure.id,
        source: 'uk',
        type: 'preferential',
        category: :suspension,
        priority: 3,
        scheme_code: nil,
        order_number: nil,
        geographical_area_description: nil,
      }
    end

    it { expect(service.call.attributes.deep_symbolize_keys).to eq(expected_table) }
  end
end
