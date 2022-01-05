require 'spec_helper'

RSpec.describe ActiveModelTypes::TariffDate do
  subject(:type) { described_class.new }

  let(:now) { Time.zone.today }

  describe '#cast' do
    context 'when passed a values hash' do
      let(:value) { { 1 => now.year, 2 => now.mon, 3 => now.mday } }

      it { expect(type.cast(value)).to eq(now) }
    end

    context 'when passed a valid iso8601 date string' do
      let(:value) { now.iso8601 }

      it { expect(type.cast(value)).to eq(now) }
    end

    context 'when passed an invalid iso8601 date string' do
      let(:value) { { 1 => now.year, 2 => now.mon, 3 => 32 } }

      it { expect(type.cast(value)).to be_nil }
    end

    context 'when passed a nil value' do
      let(:value) { nil }

      it { expect(type.cast(value)).to be_nil }
    end

    context 'when passed an empty string value' do
      let(:value) { '' }

      it { expect(type.cast(value)).to be_nil }
    end

    context 'when passed a string with just a space value' do
      let(:value) { ' ' }

      it { expect(type.cast(value)).to be_nil }
    end

    context 'when passed a string with invalid characters value' do
      let(:value) { 'ABC' }

      it { expect(type.cast(value)).to be_nil }
    end
  end
end
