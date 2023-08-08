require 'spec_helper'

RSpec.describe Footnote do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[goods_nomenclatures]) }
  end
end
