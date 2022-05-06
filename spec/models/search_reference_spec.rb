require 'spec_helper'

RSpec.describe SearchReference do
  subject(:search_reference) { build :search_reference, :with_subheading }

  it 'has correct attributes' do
    expect(search_reference).to have_attributes(id: '1',
                                                title: 'tomatoes',
                                                referenced_id: '1234567890',
                                                referenced_class: 'Subheading',
                                                productline_suffix: '12')
  end
end
