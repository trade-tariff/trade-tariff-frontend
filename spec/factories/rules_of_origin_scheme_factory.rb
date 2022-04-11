FactoryBot.define do
  factory :rules_of_origin_scheme, class: 'RulesOfOrigin::Scheme' do
    transient do
      rule_count { 3 }
      link_count { 2 }
    end

    sequence(:scheme_code) { |n| "SC#{n}" }
    sequence(:title) { |n| "Scheme title #{n}" }
    countries { %w[FR ES IT] }
    footnote { 'Scheme footnote' }
    unilateral { nil }
    fta_intro { "## Agreement\n\nDetails of agreement" }
    introductory_notes { "## Introductory notes\n\nDetails of introductory notes" }
    rules { attributes_for_list :rules_of_origin_rule, rule_count }
    links { attributes_for_list :rules_of_origin_link, link_count }
  end
end
