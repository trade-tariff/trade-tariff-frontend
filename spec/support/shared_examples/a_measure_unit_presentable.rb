RSpec.shared_examples_for 'a measure unit presentable' do
  describe '#presented_unit' do
    it 'returns the properly presented unit' do
      expect(evaluator.presented_unit).to eq(expected_presented_unit) if expected_presented_unit
    end
  end

  describe '#applicable_unit' do
    it 'returns the merged units from the ApplicableMeasureUnitMerger service' do
      expect(evaluator.applicable_unit).to eq(expected_applicable_unit)
    end
  end
end
