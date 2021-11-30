require 'spec_helper'

RSpec.describe TradingPartner, vcr: { cassette_name: 'geographical_areas#countries' } do
  subject(:trading_partner) { described_class.new(attributes) }

  let(:attributes) do
    {
      'country' => 'IT',
    }
  end

  describe 'errors' do
    before { trading_partner.valid? }

    context 'when a valid date is passed' do
      let(:attributes) { { 'country' => 'IT' } }

      it { expect(trading_partner.errors.messages).to be_empty }
    end

    context 'when an invalid date is passed' do
      let(:attributes) { { 'country' => 'FOO' } }

      it { expect(trading_partner.errors.messages[:country]).to include('Select a country') }
    end
  end
end
