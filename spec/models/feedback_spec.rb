require 'spec_helper'

RSpec.describe Feedback do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:message) }
    it { is_expected.to validate_length_of(:message).is_at_least 10 }
    it { is_expected.to validate_length_of(:message).is_at_most 500 }

    it { is_expected.to validate_length_of(:name).is_at_most 100 }

    it { is_expected.to validate_length_of(:email).is_at_most 100 }
    it { is_expected.to allow_value('hello@world.com').for(:email) }
    it { is_expected.not_to allow_value('hello@').for(:email) }
    it { is_expected.not_to allow_value('@world.com').for(:email) }
    it { is_expected.not_to allow_value('hello').for(:email) }

    it { is_expected.to validate_presence_of :authenticity_token }
    it { is_expected.to validate_length_of(:authenticity_token).is_at_least 50 }
    it { is_expected.to validate_length_of(:authenticity_token).is_at_most 100 }

    describe 'delivery limits' do
      subject { feedback.tap(&:validate).errors[:message] }

      before do
        allow(Rails.cache).to receive(:read).with(tracking_token)
                                            .and_return existing_count
      end

      let(:feedback) { build :feedback, :with_authenticity_token }
      let(:tracking_token) { feedback.send :tracking_token }

      context 'when below limit' do
        let(:existing_count) { Feedback::TOKEN_TRACKING_MAX_USAGE - 1 }

        it { is_expected.to be_empty }
      end

      context 'when on limit' do
        let(:existing_count) { Feedback::TOKEN_TRACKING_MAX_USAGE }

        it { is_expected.to include %r{too many} }
      end

      context 'when above limit' do
        let(:existing_count) { Feedback::TOKEN_TRACKING_MAX_USAGE + 1 }

        it { is_expected.to include %r{too many} }
      end
    end
  end

  describe '#record_delivery!' do
    let(:feedback) { build :feedback, :with_authenticity_token }
    let(:tracking_token) { feedback.send :tracking_token }

    before do
      allow(Rails.cache).to receive(:write)

      allow(Rails.cache).to receive(:read).with(tracking_token)
                                          .and_return existing_count
    end

    context 'when no key set' do
      let(:existing_count) { nil }

      it 'sets it' do
        feedback.record_delivery!

        expect(Rails.cache).to have_received(:write).with(tracking_token, 1, expires_in: 1.hour)
      end
    end

    context 'with key set' do
      let(:existing_count) { 2 }

      it 'sets it' do
        feedback.record_delivery!

        expect(Rails.cache).to have_received(:write).with(tracking_token, 3, expires_in: 1.hour)
      end
    end
  end
end
