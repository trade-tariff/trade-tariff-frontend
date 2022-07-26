FactoryBot.define do
  factory :rules_of_origin_scheme, class: 'RulesOfOrigin::Scheme' do
    transient do
      rule_count { 3 }
      link_count { 2 }
      article_count { 1 }
      rule_set_count { 1 }
      v2_rule_count { 2 }
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
    articles { attributes_for_list :rules_of_origin_article, article_count }

    rule_sets do
      attributes_for_list :rules_of_origin_rule_set, rule_set_count,
                          rule_count: v2_rule_count
    end

    trait :subdivided do
      rule_set_count { 3 }

      rule_sets do
        attributes_for_list :rules_of_origin_rule_set, rule_set_count,
                            :subdivided,
                            rule_count: v2_rule_count
      end
    end
  end
end
