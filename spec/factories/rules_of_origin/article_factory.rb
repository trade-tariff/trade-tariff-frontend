FactoryBot.define do
  factory :rules_of_origin_article, class: 'RulesOfOrigin::Article' do
    sequence(:article) { |n| "article-#{n}" }
    sequence(:content) { |n| "### Article #{n}\n\n* markdown list\n" }
  end
end
