require 'spec_helper'

RSpec.describe GreenLanes::EligibilityResultsController, type: :request do
  subject { make_request && response }

  before do
    allow(TradeTariffFrontend).to receive(:green_lanes_enabled?).and_return true
  end

  describe 'GET #new' do
    let(:make_request) do
      get green_lanes_eligibility_result_path,
          params: {
            moving_goods_gb_to_ni: 'yes',
            free_circulation_in_uk: 'yes',
            end_consumers_in_uk: 'yes',
            ukims: 'yes',
            t: timestamp,
          }
    end

    let(:timestamp) { Time.zone.now.to_i }

    it { is_expected.to have_http_status :ok }

    context 'when the page has expired' do
      let(:timestamp) { 11.hours.ago.to_i }

      it { is_expected.to redirect_to(green_lanes_start_path) }
    end
  end
end
