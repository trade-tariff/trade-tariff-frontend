require 'spec_helper'

RSpec.describe SearchReferencePresenter do
  subject(:presenter) { described_class.new(declarable) }

  let(:declarable) { build :search_reference, :with_subheading }

  describe '#link' do
    it { expect(presenter.link).to eq('/trade-tariff/subheadings/1234567890-12') }
  end

  describe '#to_s' do
    it { expect(presenter.to_s).to eq('Tomatoes') }
  end
end
