require 'spec_helper'

describe Heading do
  subject(:heading) { described_class.new(attributes_for(:heading).stringify_keys) }

  describe '#to_param' do
    it { expect(heading.to_param).to eq heading.short_code }
  end

  describe '#commodity_code' do
    it { expect(heading.commodity_code).to eq(heading.code) }
  end

  describe '#consigned?' do
    it { is_expected.not_to be_consigned }
  end

  describe '#heading?' do
    it { is_expected.to be_heading }
  end

  describe '#calculate_duties?' do
    it { is_expected.not_to be_calculate_duties }
  end

  describe '#rules' do
    subject(:rules) { heading.rules('FR') }

    before { allow(ProductSpecificRule).to receive(:all).and_return([]) }

    context 'with declarable heading instance' do
      before { heading.declarable = true }

      it { is_expected.to be_instance_of Array }
    end

    context 'with non declarable heading instance' do
      before { heading.declarable = false }

      it { is_expected.to be_nil }
    end
  end
end
