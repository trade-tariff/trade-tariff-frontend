require 'spec_helper'

RSpec.describe 'frontend_mailer/new_feedback', type: :view do
  let!(:feedback) { build(:feedback) }

  before do
    assign(:message, feedback.message)
    render
  end

  context 'with correct email body content' do
    it { expect(rendered).to include(feedback.message) }
  end
end
