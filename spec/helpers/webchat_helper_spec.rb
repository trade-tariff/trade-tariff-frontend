require 'spec_helper'

RSpec.describe WebchatHelper, type: :helper do
  before do
    allow(TradeTariffFrontend).to receive(:webchat_url).and_return(webchat_test_url)
  end

  let(:webchat_test_url) { 'http://webchat_test_url' }

  describe '#webchat_link' do
    it { expect(webchat_link).to include(webchat_test_url) }
  end

  describe '#webchat_visible_in_footer?' do
    context('when the controller supports webchat link') do
      let(:controller_name) { %w[commodities headings subheadings chapters sections].sample }

      it { expect(webchat_visible_in_footer?).to eq true }
    end

    context('when the controller does not support webchat link') do
      let(:controller_name) { 'measures' }

      it { expect(webchat_visible_in_footer?).to eq false }
    end
  end
end
