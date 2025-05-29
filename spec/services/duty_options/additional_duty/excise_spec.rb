RSpec.describe DutyOptions::AdditionalDuty::Excise, :user_session do
  include_context 'with a standard duty option setup', :excise

  describe '#call' do
    let(:expected_table) do
      {
        footnote: nil,
        warning_text: nil,
        values: [
          ['Excise<br><span class="govuk-green govuk-body-xs">570 - Heavy oil: other (unmarked)</span>', '8.00% * £1200.00', '£96.00'],
        ],
        value: 96,
        measure_sid: measure.id,
        source: 'uk',
        type: 'excise',
        category: :additional_duty,
        priority: 5,
        scheme_code: nil,
        order_number: nil,
        geographical_area_description: nil,
      }
    end

    it { expect(service.call.attributes.deep_symbolize_keys).to eq(expected_table) }
  end
end
