RSpec.describe CommodityContextService do
  subject(:service) { described_class.new }

  let(:commodity_source) { 'uk' }
  let(:commodity_code) { '0702000007' }
  let(:query) { { 'as_of' => '2021-01-01', 'filter[geographical_area_id]' => 'AR' } }

  it 'generates a sha of the query' do
    allow(Digest::SHA2).to receive(:hexdigest)
    service.call(commodity_source, commodity_code, query)
    expect(Digest::SHA2).to have_received(:hexdigest).with(query.to_json)
  end

  context 'when a commodity has not already been fetched' do
    before do
      allow(Api::Commodity).to receive(:build).and_call_original
    end

    it 'returns a commodity' do
      expect(service.call(commodity_source, commodity_code, query)).to be_a(Api::Commodity)
    end

    it 'calls the api builder with the passed arguments' do
      service.call(commodity_source, commodity_code, query)

      expect(Api::Commodity).to have_received(:build).with(commodity_source, commodity_code, query)
    end
  end

  context 'when a commodity has already been fetched' do
    before do
      service.call(commodity_source, commodity_code, query)
      allow(Api::Commodity).to receive(:build)
    end

    it 'returns the commodity' do
      expect(service.call(commodity_source, commodity_code, query)).to be_a(Api::Commodity)
    end

    it 'does not call the api builder' do
      service.call(commodity_source, commodity_code, query)

      expect(Api::Commodity).not_to have_received(:build)
    end
  end
end
