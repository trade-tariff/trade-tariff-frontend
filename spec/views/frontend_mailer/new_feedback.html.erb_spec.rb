require 'spec_helper'

RSpec.describe 'frontend_mailer/new_feedback', type: :view do
  let!(:feedback) { build(:feedback) }

  before do
    assign(:message, feedback.message)
    assign(:query, feedback.query)
    assign(:request_id, feedback.request_id)
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
      assign(:query, feedback.query)
      assign(:request_id, feedback.request_id)
      render
    end

    it { expect(rendered).to include(feedback.message) }
    it { expect(rendered).to include(feedback.referrer) }
    it { expect(rendered).to include(feedback.query) }
    it { expect(rendered).to include(feedback.request_id) }
  end

  context 'with page useful option' do
    before do
      assign(:message, feedback.message)
      assign(:page_useful, feedback.page_useful)
      render
    end

    it { expect(rendered).to include(feedback.message) }
    it { expect(rendered).to include(feedback.page_useful) }
  end
end
