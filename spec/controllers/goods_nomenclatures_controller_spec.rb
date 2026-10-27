require 'spec_helper'

RSpec.describe GoodsNomenclaturesController, type: :controller do
  controller(ChaptersController) {}

  describe '#backend_request_headers' do
    subject(:headers) { controller.send(:backend_request_headers) }

    before do
      controller.params = ActionController::Parameters.new(request_id: 'req-abc-123')
      controller.instance_variable_set(:@search, Search.new(search_attributes))
    end

    context 'when the date is today' do
      let(:search_attributes) { {} }

      it { is_expected.to eq('X-Search-Request-Id' => 'req-abc-123') }
    end

    context 'when the date is another day' do
      let(:search_attributes) { { 'day' => '1', 'month' => '1', 'year' => '2020' } }

      it 'asks the HTTP cache not to store the response' do
        expect(headers).to eq('X-Search-Request-Id' => 'req-abc-123', 'Cache-Control' => 'no-store')
      end
    end
  end

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
