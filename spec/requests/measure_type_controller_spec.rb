require 'spec_helper'

RSpec.describe MeasureTypeController, type: :request do
  subject { make_request && response }

  let(:measure_type) { build :measure_type }
  let(:preference_code) { build :preference_code }

  describe 'GET #show' do
    before do
      allow(MeasureType).to receive(:find)
                         .with(measure_type.id.to_s)
                         .and_return measure_type

      allow(PreferenceCode).to receive(:find)
                            .with(preference_code.code)
                            .and_return preference_code
    end

    let(:make_request) { get measure_type_path(measure_type_id: measure_type.id, preference_code_id: preference_code.code) }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{text/html} }
  end
end
