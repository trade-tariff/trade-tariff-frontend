require 'spec_helper'

RSpec.describe FrontendMailer, type: :mailer do
  describe '#new_feedback' do
    subject(:mail) { described_class.new_feedback(feedback).tap(&:deliver_now) }

    let(:feedback) { build(:feedback) }

    it { expect(mail.subject).to eq('Trade Tariff Feedback') }
    it { expect(mail.from).to eq(['no-reply@example.com']) }
    it { expect(mail.to).to eq(['support@example.com']) }
  end
end
