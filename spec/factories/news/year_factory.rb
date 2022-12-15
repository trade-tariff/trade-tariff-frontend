FactoryBot.define do
  factory :news_year, class: 'News::Year' do
    sequence(:year) { |n| Time.zone.now.year - n + 1 }
  end
end
