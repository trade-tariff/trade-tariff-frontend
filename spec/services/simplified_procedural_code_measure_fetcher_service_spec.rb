require 'spec_helper'

RSpec.describe SimplifiedProceduralCodeMeasureFetcherService do
  subject(:result) { described_class.new(params).call }

  describe '#call', vcr: { cassette_name: 'simplified_procedural_code_measures' } do
    context 'when fetching by date' do
      let(:params) { { validity_start_date: '2022-11-25' } }

      it { expect(result.measures).to all(be_a(SimplifiedProceduralCodeMeasure)) }
      it { expect(result.goods_nomenclature_label).to be_nil }
      it { expect(result.goods_nomenclature_item_ids).to be_nil }
      it { expect(result.validity_start_date).to eq('2022-11-25') }
      it { expect(result.validity_end_date).to eq('2022-12-08') }
      it { expect(result.validity_start_dates).to all(match(/\d{4}-\d{2}-\d{2}/)) }
      it { expect(result.by_date_options).to be_a(Array) }
      it { expect(result.by_code).to be(false) }
      it { expect(result.simplified_procedural_code).to be_nil }
      it { expect(result.no_data).to be_nil }
    end

    context 'when fetching by code' do
      let(:params) { { simplified_procedural_code: '2.120.1' } }

      it { expect(result.measures).to all(be_a(SimplifiedProceduralCodeMeasure)) }
      it { expect(result.goods_nomenclature_label).to eq('Apples') }
      it { expect(result.goods_nomenclature_item_ids).to eq('0808108010, 0808108020, 0808108090') }
      it { expect(result.validity_start_date).to be_nil }
      it { expect(result.validity_end_date).to be_nil }
      it { expect(result.validity_start_dates).to be_nil }
      it { expect(result.by_date_options).to be_nil }
      it { expect(result.by_code).to be(true) }
      it { expect(result.simplified_procedural_code).to eq('2.120.1') }
      it { expect(result.no_data).to be(false) }
    end

    context 'when fetching with no params' do
      let(:params) { {} }

      it { expect(result.measures).to all(be_a(SimplifiedProceduralCodeMeasure)) }
      it { expect(result.goods_nomenclature_label).to be_nil }
      it { expect(result.goods_nomenclature_item_ids).to be_nil }
      it { expect(result.validity_start_date).to eq('2025-07-04') }
      it { expect(result.validity_end_date).to eq('2025-07-17') }
      it { expect(result.validity_start_dates).to all(match(/\d{4}-\d{2}-\d{2}/)) }
      it { expect(result.by_date_options).to be_a(Array) }
      it { expect(result.by_code).to be(false) }
      it { expect(result.simplified_procedural_code).to be_nil }
      it { expect(result.no_data).to be_nil }
    end

    context 'when no measures are returned by code' do
      let(:params) { { simplified_procedural_code: 'nonexistent-code' } }

      before do
        allow(SimplifiedProceduralCodeMeasure).to receive(:by_code).and_return([])
      end

      it 'does not raise an error' do
        expect { result }.not_to raise_error
      end
    end
  end
end
