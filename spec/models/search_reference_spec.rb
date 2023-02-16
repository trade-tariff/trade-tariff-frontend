require 'spec_helper'

RSpec.describe SearchReference do
  subject(:search_reference) { build :search_reference, :with_subheading }

  it 'has correct attributes' do
    expect(search_reference).to have_attributes(id: '1',
                                                title: 'tomatoes',
                                                referenced_id: '8418690000-10',
                                                referenced_class: 'Subheading',
                                                productline_suffix: '10')
  end
end
