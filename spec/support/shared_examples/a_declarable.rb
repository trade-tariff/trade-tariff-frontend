RSpec.shared_examples 'a declarable' do
  it { is_expected.to respond_to(:declarable) }

  let(:measures) { [] }
  let(:footnotes) { [] }

  describe '#supplementary_unit' do
    context 'when there is a supplementary measure' do
      let(:measures) do
        [
          attributes_for(
            :measure,
            :import_export_supplementary,
            :erga_omnes,
            :with_supplementary_measure_components,
          ),
        ]
      end

      it 'returns the appropriate supplementary unit' do
        expect(declarable.supplementary_unit).to eq('Number of items (p/st)')
      end
    end

    context 'when there is no official supplementary measure but there are excise units' do
      let(:measures) do
        [
          attributes_for(
            :measure,
            :excise,
            :erga_omnes,
            :with_supplementary_measure_components,
          ),
        ]
      end

      it 'returns the appropriate supplementary unit classification' do
        expect(declarable.supplementary_unit).to eq('There are no supplementary unit measures assigned to this commodity, however you will need to declare the unit of import (number of items) for excise purposes.')
      end
    end

    context 'when there are no supplementary measures' do
      let(:measures) { [attributes_for(:measure)] }

      it 'returns the appropriate supplementary unit classification' do
        expect(declarable.supplementary_unit).to eq('There are no supplementary unit measures assigned to this commodity')
      end
    end
  end

  describe '#supplementary_unit_description' do
    context 'when there is a supplementary measure and the measure is an import measure' do
      let(:measures) do
        [
          attributes_for(
            :measure,
            :import_only_supplementary,
            :erga_omnes,
            :with_supplementary_measure_components,
          ),
        ]
      end

      it 'returns the appropriate description' do
        expect(declarable.supplementary_unit_description).to eq('Supplementary unit (import)')
      end
    end

    context 'when there is a supplementary measure and the measure is an export measure' do
      let(:measures) do
        [
          attributes_for(
            :measure,
            :import_export_supplementary,
            :erga_omnes,
            :with_supplementary_measure_components,
          ),
        ]
      end

      it 'returns the appropriate description' do
        expect(declarable.supplementary_unit_description).to eq('Supplementary unit')
      end
    end

    context 'when there are no supplementary measures' do
      let(:measures) { [attributes_for(:measure)] }

      it 'returns the appropriate description' do
        expect(declarable.supplementary_unit_description).to eq('Supplementary unit')
      end
    end

    describe '#critical_footnotes' do
      context 'when there are critical footnotes' do
        let(:footnotes) { [attributes_for(:footnote, code: 'CR123')] }

        it 'returns the critical footnotes' do
          expect(declarable.critical_footnotes.first.code).to eq('CR123')
        end
      end

      context 'when there are NOT Critical footnotes' do
        let(:footnotes) { [attributes_for(:footnote, code: 'NC456')] }

        it 'returns empty array' do
          expect(declarable.critical_footnotes).to eq([])
        end
      end
    end
  end
end
