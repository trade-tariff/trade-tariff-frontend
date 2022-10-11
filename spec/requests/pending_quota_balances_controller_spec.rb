require 'spec_helper'

RSpec.describe PendingQuotaBalancesController, type: :request do
  subject { make_request && response }

  describe 'GET #show' do
    before { allow(PendingQuotaBalanceService).to receive(:new).and_return service }

    let(:service) { instance_double PendingQuotaBalanceService, call: '1000.0' }
    let(:make_request) { get pending_quota_balance_path('1234567890', '123456') }

    it { is_expected.to have_http_status :ok }
    it { is_expected.to have_attributes content_type: %r{application/json} }
  end
end
