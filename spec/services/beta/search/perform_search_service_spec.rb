require 'spec_helper'

RSpec.describe Beta::Search::PerformSearchService do
  describe '#call' do
    subject(:call) { described_class.new(query, filters).call }

    before do
      host = TradeTariffFrontend::ServiceChooser.api_host
      path = '/api/beta/search'
      params = '?filter%5Banimal_type%5D=swine&filter%5Bgoods_nomenclature_class%5D=Commodity,Subheading&q=running%20horses'
      url = "#{host}#{path}#{params}"

      search_result = jsonapi_response(
        :search_result,
        attributes_for(:search_result),
      )

      stub_request(:get, url).to_return(search_result)
    end

    let(:query) { 'running horses' }
    let(:filters) { { animal_type: 'swine', goods_nomenclature_class: %w[Commodity Subheading] } }

    it { is_expected.to be_a(Beta::Search::SearchResult) }
  end
end
