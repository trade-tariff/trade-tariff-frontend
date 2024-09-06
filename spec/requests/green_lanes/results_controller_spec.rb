require 'spec_helper'

RSpec.describe GreenLanes::ResultsController, type: :request do
  subject { make_request && response }

  before do
    allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return true
  end

  describe 'when users try to directly access the result page it redirects to the start page' do
    let(:make_request) { get green_lanes_result_path }

    it { is_expected.to have_http_status :redirect }
    it { is_expected.to redirect_to(green_lanes_start_path) }
  end
end
