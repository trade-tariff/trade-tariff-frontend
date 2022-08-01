require 'spec_helper'

RSpec.describe Beta::Search::Guide do
  subject(:guide) { build(:guide) }

  it { is_expected.to have_attributes(title: 'Herbal medicines',
                                      url: 'Get help to classify herbal medicines',
                                      strapline: 'This is the guide for Herbal medicines')
  }
end
