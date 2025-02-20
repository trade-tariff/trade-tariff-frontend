require 'spec_helper'

RSpec.describe SimplifiedProceduralValuesController, type: :request do
  describe 'GET #index', vcr: { cassette_name: 'simplified_procedural_code_measures' } do
    let(:result) { assigns(:result) }

    context 'when simplified_procedural_code is present' do
      let(:simplified_procedural_code) { '2.120.1' }

      before do
        get simplified_procedural_values_path(simplified_procedural_code:)
      end

      it { expect(response).to render_template(:index) }
      it { expect(result.measures).to all(be_a(SimplifiedProceduralCodeMeasure)) }
      it { expect(result.by_code).to be(true) }
    end

    context 'when validity_start_date is present' do
      let(:validity_start_date) { '2022-11-25' }

      before do
        get simplified_procedural_values_path(validity_start_date:)
      end

      it { expect(response).to render_template(:index) }
      it { expect(result.measures).to all(be_a(SimplifiedProceduralCodeMeasure)) }
      it { expect(result.by_code).to be(false) }
    end

    context 'when no filters are present' do
      before do
        get simplified_procedural_values_path
      end

      it { expect(response).to render_template(:index) }
      it { expect(result.measures).to all(be_a(SimplifiedProceduralCodeMeasure)) }
    end
  end
end
