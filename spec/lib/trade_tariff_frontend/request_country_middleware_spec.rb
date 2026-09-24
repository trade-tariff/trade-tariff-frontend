require 'spec_helper'

RSpec.describe TradeTariffFrontend::RequestCountryMiddleware do
  subject(:request_headers) do
    headers = nil
    connection = Faraday.new do |faraday|
      faraday.use described_class
      faraday.adapter :test do |stub|
        stub.get('/') do |env|
          headers = env.request_headers
          [200, {}, '']
        end
      end
    end
    connection.get('/')
    headers
  end

  it 'forwards the current request country' do
    Current.request_country = ActiveSupport::StringInquirer.new('gb')

    expect(request_headers['X-Request-Country']).to eq('gb')
  end

  it 'forwards unknown when unavailable' do
    expect(request_headers['X-Request-Country']).to eq('unknown')
  end
end
