require 'spec_helper'

RSpec.describe GuidedSearch::QueuedSearch do
  subject(:result) { described_class.find(id).fetch('result') }

  let(:id) { 'aabbccdd-1234-4567-8901-aabbccddeeff' }
  let(:resource_class) { 'UnknownThing' }

  before do
    stub_api_request("queued_searches/#{id}", internal: true).to_return(
      status: 200,
      headers: { 'content-type' => 'application/json' },
      body: {
        id:,
        status: 'completed',
        response_status: 200,
        result: { data: [{
          id: '0101210000',
          type: 'commodity',
          attributes: { goods_nomenclature_class: resource_class, goods_nomenclature_item_id: '0101210000' },
        }] },
      }.to_json,
    )
  end

  it 'retains the shared parser fallback for an unknown backend class' do
    expect(result.all.first).to be_an_instance_of(GoodsNomenclature)
  end

  context 'with a known backend class' do
    let(:resource_class) { 'Commodity' }

    it 'retains the specialised model' do
      expect(result.all.first).to be_an_instance_of(Commodity)
    end
  end

  context 'with a future valid model subclass' do
    let(:resource_class) { 'FutureGoodsNomenclature' }

    before { stub_const('FutureGoodsNomenclature', Class.new(GoodsNomenclature)) }

    it 'accepts subclasses outside the current controller map' do
      expect(result.all.first).to be_an_instance_of(FutureGoodsNomenclature)
    end
  end

  [nil, '', ' ', 123, {}, 'Hash', 'Array', 'String', 'Kernel'].each do |malformed|
    context "with malformed class #{malformed.inspect}" do
      let(:resource_class) { malformed }

      it 'rejects the malformed result' do
        expect { result }.to raise_error(described_class::InvalidResponse)
      end
    end
  end
end
