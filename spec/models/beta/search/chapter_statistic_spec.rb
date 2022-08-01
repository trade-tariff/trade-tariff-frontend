require 'spec_helper'

RSpec.describe Beta::Search::ChapterStatistic do
  subject(:chapter_statistic) { build(:chapter_statistic) }

  it {
    expect(chapter_statistic).to have_attributes(description: 'Chapter statistics',
                                                 cnt: 1,
                                                 score: 17.5,
                                                 avg: 17.5)
  }
end
