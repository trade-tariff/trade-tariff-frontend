RSpec.describe DutyCalculator::Api::RulesOfOriginScheme do
  subject(:rules_of_origin_scheme) { build(:duty_calculator_rules_of_origin_scheme) }

  it_behaves_like 'a has_many relationship', :rules
  it_behaves_like 'a has_many relationship', :links
  it_behaves_like 'a has_many relationship', :proofs

  it_behaves_like 'a resource that has attributes',
                  scheme_code: 'albania',
                  title: 'UK-Albania partnership, Trade and Cooperation Agreement',
                  countries: %w[AL],
                  footnote: nil,
                  fta_intro: '### UK-Albania partnership, trade and cooperation agreement\n\n',
                  introductory_notes: '### Note 1:\n\nThe list sets out the conditions required for all products to be considered as sufficiently worked',
                  unilateral: nil
end
