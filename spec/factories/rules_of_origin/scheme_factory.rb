FactoryBot.define do
  factory :rules_of_origin_scheme, class: 'RulesOfOrigin::Scheme' do
    transient do
      rule_count { 3 }
      link_count { 2 }
      article_count { 1 }
      rule_set_count { 1 }
      v2_rule_count { 2 }
      proof_count { 1 }
    end

    sequence(:scheme_code) { |n| "SC#{n}" }
    sequence(:title) { |n| "Scheme title #{n}" }
    countries { %w[FR ES IT] }
    footnote { 'Scheme footnote' }
    unilateral { nil }
    fta_intro { "## Agreement\n\nDetails of agreement" }
    introductory_notes { "## Introductory notes\n\nDetails of introductory notes" }
    cumulation_methods do
      {
        'bilateral' => %w[GB CA],
        'extended' => %w[EU AD],
      }
    end
    rules { attributes_for_list :rules_of_origin_rule, rule_count }
    links { attributes_for_list :rules_of_origin_link, link_count }
    articles { attributes_for_list :rules_of_origin_article, article_count }
    proofs { attributes_for_list :rules_of_origin_proof, proof_count }
    show_proofs_for_geographical_areas { [] } # if empty it is ignored
    origin_reference_document { attributes_for :rules_of_origin_origin_reference_document }

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

    trait :rules_with_footnotes do
      rule_set_count { 1 }

      rule_sets do
        attributes_for_list(:rules_of_origin_rule_set, rule_set_count).each do |rule_set_attributes|
          rule_set_attributes[:rules] = attributes_for_list(:rules_of_origin_v2_rule, v2_rule_count, :with_footnote)
        end
      end
    end

    trait :mixed_subdivision do
      rule_set_count { 3 }

      rule_sets do
        attributes_for_list(:rules_of_origin_rule_set, rule_set_count - 1,
                            :subdivided,
                            rule_count: v2_rule_count) +
          attributes_for_list(:rules_of_origin_rule_set, 1, rule_count: v2_rule_count)
      end
    end

    trait :other_subdivision do
      mixed_subdivision
    end

    trait :single_wholly_obtained_rule do
      rule_sets do
        attributes_for_list \
          :rules_of_origin_rule_set, 1,
          rules: attributes_for_list(:rules_of_origin_v2_rule, 1, :wholly_obtained)
      end
    end

    trait :with_cds_proof_info do
      proof_intro { 'Some intro text' }

      proof_codes do
        {
          'abc' => 'Description **with markdown**',
          'def' => 'Second description',
        }
      end
    end
  end
end
