require 'spec_helper'

RSpec.describe Section do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[chapters]) }
  end
end
