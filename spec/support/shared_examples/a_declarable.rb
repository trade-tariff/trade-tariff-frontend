RSpec.shared_examples 'a declarable' do
  it { is_expected.to respond_to(:declarable) }

  let(:measures) { [] }

  describe '#supplementary_unit' do
    context 'when there is a supplementary measure' do
      let(:measures) do
        [
          attributes_for(:measure, :import_export_supplementary, :erga_omnes, :with_supplementary_measure_components),
        ]
      end

      it 'returns the appropriate supplementary unit' do
        expect(declarable.supplementary_unit(country: '1011')).to eq('Number of items (p/st)')
      end
    end

    context 'when there are no supplementary measures' do
      let(:measures) { [attributes_for(:measure)] }

      it 'returns the appropriate supplementary unit' do
        expect(declarable.supplementary_unit(country: '1011')).to eq('No supplementary unit required.')
      end
    end
  end

  describe '#supplementary_unit_description' do
    context 'when there is a supplementary measure and the measure is an import measure' do
      let(:measures) do
        [
          attributes_for(:measure, :import_only_supplementary, :erga_omnes, :with_supplementary_measure_components),
        ]
      end

      it 'returns the appropriate description' do
        expect(declarable.supplementary_unit_description(country: '1011')).to eq('Supplementary unit (import)')
      end
    end

    context 'when there is a supplementary measure and the measure is an export measure' do
      let(:measures) do
        [
          attributes_for(:measure, :import_export_supplementary, :erga_omnes, :with_supplementary_measure_components),
        ]
      end

      it 'returns the appropriate description' do
        expect(declarable.supplementary_unit_description(country: '1011')).to eq('Supplementary unit')
      end
    end

    context 'when there are no supplementary measures' do
      let(:measures) { [attributes_for(:measure)] }

      it 'returns the appropriate description' do
        expect(declarable.supplementary_unit_description(country: '1011')).to eq('Supplementary unit')
      end
    end
  end
end
