require 'spec_helper'

RSpec.describe Feedback do
  subject(:feedback) { build(:feedback, message:) }

  describe 'validations' do
    before { feedback.valid? }

    context 'when feedback > 500' do
      let(:message) { 'A' * 501 }

      it { expect(feedback.errors.map(&:type)).to include(:too_long) }
    end

    context 'when feedback is empty' do
      let(:message) { '' }

      it { expect(feedback.errors.map(&:type)).to include(:blank, :too_short) }
    end
  end
end
