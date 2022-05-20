require 'spec_helper'

RSpec.describe Chapter do
  describe '.relationships' do
    let(:expected_relationships) { %i[section headings] }

    it { expect(described_class.relationships).to eq(expected_relationships) }
  end
end
