FactoryBot.define do
  factory :duty_calculator_rules_of_origin_scheme, class: 'DutyCalculator::Api::RulesOfOriginScheme' do
    scheme_code { 'albania' }
    title { 'UK-Albania partnership Trade and Cooperation Agreement' }
    countries { %w[AL] }
    footnote { nil }
    fta_intro { '### UK-Albania partnership trade and cooperation agreement\n\n' }
    introductory_notes { '### Note 1:\n\nThe list sets out the conditions required for all products to be considered as sufficiently worked' }
    unilateral { nil }
    rules { [] }
    links { [] }
    proofs { [] }
  end
end
