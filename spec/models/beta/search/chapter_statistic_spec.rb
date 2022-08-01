require 'spec_helper'

RSpec.describe Beta::Search::ChapterStatistic do
  subject(:chapter_statistics) { build(:chapter_statistic) }

  it {
    expect(subject).to have_attributes({ description: 'Chapter statistics',
                                         cnt: 1,
                                         score: 17.5,
                                         avg: 17.5 })
  }
end
