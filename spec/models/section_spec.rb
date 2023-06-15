require 'spec_helper'

RSpec.describe Section do
  it { is_expected.to respond_to :description_plain }

  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[chapters]) }
  end
end
