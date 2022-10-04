require 'spec_helper'

RSpec.describe QuotaDefinitionHelper, type: :helper do
  describe '#start_and_end_dates_for' do
    let(:definition) { build(:definition, validity_start_date: '2021-01-01T00:00:00.000Z', validity_end_date: '2021-12-31T00:00:00.000Z') }

    it 'returns a properly formatted definition' do
      expect(helper.start_and_end_dates_for(definition)).to eq('1 January 2021 to 31 December 2021')
    end
  end
end
