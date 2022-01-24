require 'spec_helper'

RSpec.describe ClientLocation do
  subject(:client_location) { described_class.new(headers) }

  let(:headers) { { 'CloudFront-Viewer-Country-Name' => location } }

  describe '#unknown?' do
    subject { client_location.unknown? }

    context 'without header' do
      let(:headers) { {} }

      it { is_expected.to be true }
    end

    context 'with header' do
      let(:location) { 'United Kingdom' }

      it { is_expected.to be false }
    end
  end

  describe '#united_kingdom?' do
    subject { client_location.united_kingdom? }

    context 'without header' do
      let(:headers) { {} }

      it { is_expected.to be false }
    end

    context 'with header for somewhere else' do
      let(:location) { 'France' }

      it { is_expected.to be false }
    end

    context 'with header for UK' do
      let(:location) { 'United Kingdom' }

      it { is_expected.to be true }
    end
  end
end
