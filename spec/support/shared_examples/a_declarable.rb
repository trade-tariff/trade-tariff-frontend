RSpec.shared_examples 'a declarable' do
  it { is_expected.to respond_to(:declarable) }

  let(:measures) { [] }

  describe '#supplementary_unit' do
    context 'when there there is one supplementary_measures' do
      let(:measures) do
        [
          attributes_for(:measure, :supplementary, :with_supplementary_measure_components),
        ]
      end

      it 'return appropriate notice message' do
        expect(declarable.supplementary_unit).to eq('Number of items (p/st)')
      end
    end

    context 'when there are not supplementary_measures' do
      it 'return appropriate notice message' do
        expect(declarable.supplementary_unit).to eq('No supplementary unit required.')
      end
    end

    context 'when there are more than one supplementary_measures' do
      let(:measures) do
        [
          attributes_for(:measure, :supplementary, :with_supplementary_measure_components),
          attributes_for(:measure, :supplementary, :with_supplementary_measure_components),
        ]
      end

      it 'return appropriate notice message' do
        expect(declarable.supplementary_unit).to eq('There are multiple supplementary units for you trade. See measures below.')
      end
    end
  end
end
