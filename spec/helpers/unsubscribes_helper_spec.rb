require 'spec_helper'

RSpec.describe UnsubscribesHelper, type: :helper do
  describe '#unsubscribe_confirmation_content' do
    context 'when subscription_type is stop_press' do
      let(:content) { helper.unsubscribe_confirmation_content('stop_press') }

      it 'returns the correct header' do
        expect(content[:header]).to eq('You have unsubscribed')
      end

      it 'returns the correct message' do
        expect(content[:message]).to eq('You will no longer receive any Stop Press emails from the UK Trade Tariff Service.')
      end
    end

    context 'when subscription_type is my_commodities' do
      let(:content) { helper.unsubscribe_confirmation_content('my_commodities') }

      it 'returns the correct header' do
        expect(content[:header]).to eq('You have unsubscribed from your commodity watch list')
      end

      it 'returns the correct message' do
        expect(content[:message]).to eq('You will no longer have access to your commodity watch list dashboard or receive email notifications.<br><br>If you have other UK Trade Tariff subscriptions, they will continue')
      end
    end
  end
end
