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
      it { expect(result.goods_nomenclature_label).to eq('Amarillo, cuper, honeydew, (including cantalene), (onteniente, piel de sapo (including verde liso), rochet, tendral, futuro') }
      it { expect(result.goods_nomenclature_item_ids).to eq('0807190050') }
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
      it { expect(result.validity_start_date).to eq('2023-05-12') }
      it { expect(result.validity_end_date).to eq('2023-05-25') }
      it { expect(result.validity_start_dates).to all(match(/\d{4}-\d{2}-\d{2}/)) }
      it { expect(result.by_date_options).to be_a(Array) }
      it { expect(result.by_code).to be(false) }
      it { expect(result.simplified_procedural_code).to be_nil }
      it { expect(result.no_data).to be_nil }
    end
  end
end
