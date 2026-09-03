require 'spec_helper'

RSpec.describe TradeTariffFrontend::RequestCountry do
  describe '.normalize' do
    it { expect(described_class.normalize('GB')).to eq('gb') }
    it { expect(described_class.normalize(nil)).to eq('') }
    it { expect(described_class.normalize('not-a-country')).to eq('') }
  end
end
