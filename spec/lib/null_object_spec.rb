require 'spec_helper'

RSpec.describe NullObject do
  let(:stub_attrs) { { foo: 'bar' } }
  let(:null_object) { described_class.new(stub_attrs) }

  describe '#present?' do
    subject { null_object.present? }

    it { is_expected.to be false }
  end

  describe '#empty?' do
    subject { null_object.empty? }

    it { is_expected.to be true }
  end

  describe '#blank?' do
    subject { null_object.blank? }

    it { is_expected.to be true }
  end

  describe '#method_missing' do
    subject { null_object.foo }

    it { is_expected.to eq 'bar' }
  end

  describe '#to_s' do
    subject { null_object.to_s }

    it { is_expected.to be_nil }
  end
end
