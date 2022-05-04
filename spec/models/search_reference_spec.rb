require 'spec_helper'

RSpec.describe SearchReference do
  subject { build :search_reference, :with_subheading }

    it 'has correct attributes' do
      is_expected.to have_attributes(id: '1',
        title: 'tomatoes',
        referenced_id: '1234567890',
        referenced_class: 'Subheading',
        productline_suffix: '12')
    end
end
