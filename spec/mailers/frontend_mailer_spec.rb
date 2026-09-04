require 'spec_helper'

RSpec.describe FrontendMailer, type: :mailer do
  describe '#new_feedback' do
    subject(:mail) { described_class.new_feedback(feedback).tap(&:deliver_now) }

    let(:feedback) { build(:feedback) }

    it { expect(mail.subject).to eq('Trade Tariff Feedback') }
    it { expect(mail.from).to eq(['no-reply@example.com']) }
    it { expect(mail.to).to eq(['support@example.com']) }

    context 'with enabled feature flags' do
      let(:feedback) { build(:feedback, feature_flags: %w[interactive_search webchat]) }

      it 'includes their names' do
        expect(mail.body).to include('Feature flags: interactive_search, webchat')
      end
    end

    context 'without enabled feature flags' do
      it 'reports none' do
        expect(mail.body).to include('Feature flags: None')
      end
    end
  end
end
