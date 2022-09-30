require 'spec_helper'

RSpec.describe Beta::Search::Guide do
  subject(:guide) { build(:guide) }

  it {
    expect(guide).to have_attributes(title: 'Herbal medicines',
                                     url: 'Get help to classify herbal medicines',
                                     strapline: 'This is the guide for Herbal medicines',
                                     image: 'medicines.png')
  }
end
