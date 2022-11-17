FactoryBot.define do
  factory :rules_of_origin_article, class: 'RulesOfOrigin::Article' do
    sequence(:article) { |n| "article-#{n}" }
    sequence(:content) { |n| "### Article #{n}\n\n* markdown list\n" }

    trait :ord_reference do
      content { "### Some information\n\n{{ articles 32 to 33 }}" }
    end
  end
end
