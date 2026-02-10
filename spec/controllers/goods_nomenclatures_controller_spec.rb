require 'spec_helper'

RSpec.describe GoodsNomenclaturesController, type: :controller do
  controller(ChaptersController) {}

  describe '#search_tracking_headers' do
    subject { controller.send(:search_tracking_headers) }

    context 'when request_id is present' do
      before { controller.params = ActionController::Parameters.new(request_id: 'req-abc-123') }

      it { is_expected.to eq('X-Search-Request-Id' => 'req-abc-123') }
    end

    context 'when request_id is blank' do
      before { controller.params = ActionController::Parameters.new(request_id: '') }

      it { is_expected.to eq({}) }
    end

    context 'when request_id is absent' do
      before { controller.params = ActionController::Parameters.new({}) }

      it { is_expected.to eq({}) }
    end
  end
end
