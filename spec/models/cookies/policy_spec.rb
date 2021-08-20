require 'spec_helper'

RSpec.describe Cookies::Policy do
  subject(:policy) { described_class.new nil }

  let(:cookie) do
    {
      settings: true,
      usage: 'true',
      remember_settings: 'false',
    }.to_json
  end

  describe 'attributes' do
    it { is_expected.to respond_to :settings }
    it { is_expected.to respond_to :usage }
    it { is_expected.to respond_to :remember_settings }

    describe '#settings=' do
      context 'with value' do
        before { policy.settings = false }

        it { is_expected.to have_attributes settings: true }
      end

      context 'with nil' do
        before { policy.settings = nil }

        it { is_expected.to have_attributes settings: true }
      end
    end

    describe '#usage=' do
      context 'with value' do
        before { policy.usage = 'false' }

        it { is_expected.to have_attributes usage: 'false' }
      end

      context 'with blank' do
        before { policy.usage = '' }

        it { is_expected.to have_attributes usage: nil }
      end

      context 'with nil' do
        before { policy.usage = nil }

        it { is_expected.to have_attributes usage: nil }
      end
    end

    describe '#remember_settings=' do
      context 'with value' do
        before { policy.remember_settings = 'false' }

        it { is_expected.to have_attributes remember_settings: 'false' }
      end

      context 'with blank' do
        before { policy.remember_settings = '' }

        it { is_expected.to have_attributes remember_settings: nil }
      end

      context 'with nil' do
        before { policy.remember_settings = nil }

        it { is_expected.to have_attributes remember_settings: nil }
      end
    end

    describe '#acceptance=' do
      context 'with accept' do
        before { policy.acceptance = 'accept' }

        it { is_expected.to have_attributes settings: true }
        it { is_expected.to have_attributes usage: 'true' }
        it { is_expected.to have_attributes remember_settings: 'true' }
      end

      context 'with reject' do
        before { policy.acceptance = 'reject' }

        it { is_expected.to have_attributes settings: true }
        it { is_expected.to have_attributes usage: 'false' }
        it { is_expected.to have_attributes remember_settings: 'false' }
      end

      context 'with no value' do
        before { policy.acceptance = '' }

        it { is_expected.to have_attributes settings: true }
        it { is_expected.to have_attributes usage: nil }
        it { is_expected.to have_attributes remember_settings: nil }
      end
    end
  end

  describe '.from_cookie' do
    subject { described_class.from_cookie cookie }

    it { is_expected.to have_attributes settings: true }
    it { is_expected.to have_attributes usage: 'true' }
    it { is_expected.to have_attributes remember_settings: 'false' }
  end

  describe '.to_cookie' do
    subject { instance.to_cookie }

    let(:instance) do
      described_class.new(usage: 'true', remember_settings: 'false')
    end

    it { is_expected.to eql cookie }
  end
end
