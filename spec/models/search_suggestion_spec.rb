require 'spec_helper'

RSpec.describe SearchSuggestion do
  subject { build(:search_suggestion) }

  it { is_expected.to have_attributes(score: 0.1124, query: 'test', value: 'test') }
end
