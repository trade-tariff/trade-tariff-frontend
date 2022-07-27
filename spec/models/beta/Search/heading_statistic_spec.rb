require 'spec_helper'

RSpec.describe Beta::Search::HeadingStatistic do
  subject(:heading_statistic) { build(:heading_statistic) }

  it {
    expect(subject).to have_attributes(description: 'Heading statistics',
                                       chapter_id: 10,
                                       chapter_description: 'Chapter description',
                                       score: 200.5,
                                       cnt: 2,
                                       avg: 88.7,
                                       chapter_score: 120.3)
  }
end
