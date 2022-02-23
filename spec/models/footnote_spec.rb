require 'spec_helper'

RSpec.describe Footnote do
  describe '.relationships' do
    it { expect(described_class.relationships).to eq(%i[measures goods_nomenclatures]) }
  end

  describe '#id' do
    let(:measure) { Measure.new(attributes_for(:measure, id: '123').stringify_keys) }
    let(:footnote) { described_class.new(attributes_for(:footnote, casted_by: measure, code: '456').stringify_keys) }

    it 'contains casted_by info' do
      expect(footnote.id).to include(footnote.casted_by.destination)
      expect(footnote.id).to include(footnote.casted_by.id)
    end

    it 'contains code' do
      expect(footnote.id).to include(footnote.code)
    end

    it "contains '-footnote-'" do
      expect(footnote.id).to include('-footnote-')
    end
  end

  describe '#eco?' do
    let(:footnote) { described_class.new(attributes_for(:footnote, code: described_class::ECO_CODE).stringify_keys) }
    let(:footnote1) { described_class.new(attributes_for(:footnote).stringify_keys) }

    it 'returns true if ECO code' do
      expect(footnote.eco?).to be_truthy
    end

    it 'returns false if not ECO code' do
      expect(footnote1.eco?).to be_falsey
    end
  end
end
