require 'spec_helper'

RSpec.describe AdditionalCodeSearchService, vcr: { cassette_name: 'search#additional_code_search_results_8180' } do
  describe '#call' do
    subject(:call) { described_class.new(query_params).call }

    before do
      allow(AdditionalCode).to receive(:search).and_call_original

      call
    end

    context 'when search params are valid' do
      let(:query_params) { { code: '180', type: '8' } }

      it { expect(AdditionalCode).to have_received(:search).with(query_params) }
      it { is_expected.to all(be_a(AdditionalCode)) }
      it { expect(call.count).to eq(1) }
    end

    context 'when the query params are empty' do
      let(:query_params) { {} }

      it { is_expected.to be_empty }
      it { expect(AdditionalCode).not_to have_received(:search) }
    end
  end
end
