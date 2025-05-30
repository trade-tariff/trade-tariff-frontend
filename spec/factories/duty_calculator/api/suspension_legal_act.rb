FactoryBot.define do
  factory :duty_calculator_suspension_legal_act, class: 'DutyCalculator::Api::SuspensionLegalAct' do
    id {}
    validity_end_date {}
    validity_start_date {}
    regulation_code {}
    regulation_url {}
  end
end
