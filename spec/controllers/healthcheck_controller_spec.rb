require 'spec_helper'

RSpec.describe HealthcheckController, type: :controller do
  it 'returns success on request' do
    allow(Section).to receive(:all).and_return([])

    get :check
    expect(response.status).to eq 200
  end

  it 'throws a 500 on no API connection' do
    allow(Section).to receive(:all)
                      .and_raise(Faraday::ServerError, 'Bad request')

    get :check
    expect(response.status).to eq 500
  end
end
