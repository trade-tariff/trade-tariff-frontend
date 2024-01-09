require 'spec_helper'

RSpec.describe 'frontend_mailer/new_feedback', type: :view do
  let!(:feedback) { build(:feedback) }

  before do
    assign(:message, feedback.message)
    render
  end

  context 'with message' do
    it { expect(rendered).to include(feedback.message) }
    it { expect(rendered).not_to include(feedback.referrer) }
  end

  context 'with message and url' do
    before do
      assign(:message, feedback.message)
      assign(:url, feedback.referrer)
      render
    end

    it { expect(rendered).to include(feedback.message) }
    it { expect(rendered).to include(feedback.referrer) }
  end
end
