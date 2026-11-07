require 'spec_helper'

RSpec.describe GuidedSearch::ImageDescription do
  let(:id) { 'aabbccdd-1234-4567-8901-aabbccddeeff' }
  let(:headers) { { 'content-type' => 'application/json' } }
  let(:payload) { { id:, status: 'completed', description: 'A cotton shirt.', uncertainties: [] } }

  before do
    stub_api_request("image_descriptions/#{id}", internal: true).to_return(status: 200, headers:, body: payload.to_json)
  end

  it 'returns the bounded description and uncertainties' do
    expect(described_class.find(id)).to eq('status' => 'completed', 'description' => 'A cotton shirt.', 'uncertainties' => [])
  end

  [nil, [], {}, { id: 'wrong', status: 'running' }].each do |invalid|
    it "rejects malformed payload #{invalid.inspect}" do
      stub_api_request("image_descriptions/#{id}", internal: true).to_return(status: 200, headers:, body: invalid.to_json)
      expect { described_class.find(id) }.to raise_error(described_class::InvalidResponse)
    end
  end

  [nil, '', ' ' * 5, 'x' * 1001, 42].each do |description|
    it "rejects invalid completed description of type/length #{description.class}/#{description.to_s.length}" do
      payload[:description] = description
      stub_api_request("image_descriptions/#{id}", internal: true).to_return(status: 200, headers:, body: payload.to_json)
      expect { described_class.find(id) }.to raise_error(described_class::InvalidResponse)
    end
  end

  it 'rejects malformed uncertainty data' do
    payload[:uncertainties] = [42]
    stub_api_request("image_descriptions/#{id}", internal: true).to_return(status: 200, headers:, body: payload.to_json)
    expect { described_class.find(id) }.to raise_error(described_class::InvalidResponse)
  end

  it 'rejects non-UUID identifiers before reading the backend' do
    expect { described_class.find('../other') }.to raise_error(described_class::InvalidResponse)
  end
end
