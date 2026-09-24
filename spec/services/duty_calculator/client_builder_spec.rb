require 'spec_helper'

RSpec.describe DutyCalculator::ClientBuilder do
  subject(:build_client) { described_class.new(:uk).call }

  let(:connection) { Faraday::Connection.new }

  before do
    allow(Faraday).to receive(:new).and_yield(connection).and_return(connection)
    allow(Uktt::Http).to receive(:new)
  end

  it 'adds the request country middleware' do
    build_client

    expect(connection.builder.handlers).to include(TradeTariffFrontend::RequestCountryMiddleware)
  end
end
