FactoryBot.define do
  factory :chapter_statistic, class: 'Beta::Search::ChapterStatistic' do
    description { 'Chapter statistics' }
    cnt { 1 }
    score { 17.5 }
    avg { 17.5 }
  end
end
