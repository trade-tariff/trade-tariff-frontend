require 'spec_helper'

RSpec.describe Chapter do
  describe '.relationships' do
    let(:expected_relationships) { %i[ancestors section headings] }

    it { expect(described_class.relationships).to match_array(expected_relationships) }
  end
end
