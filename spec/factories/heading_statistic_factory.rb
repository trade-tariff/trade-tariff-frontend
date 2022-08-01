FactoryBot.define do
  factory :heading_statistic, class: 'Beta::Search::HeadingStatistic' do
    description { 'Heading statistics' }
    chapter_id  { 10 }
    chapter_description { 'Chapter description' }
    score { 200.5 }
    cnt { 2 }
    avg { 88.7 }
    chapter_score { 120.3 }
  end
end
