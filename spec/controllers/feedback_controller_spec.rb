require 'spec_helper'

RSpec.describe FeedbackController, type: :controller do
  describe 'GET #new' do
    before do
      get :new
    end

    it { is_expected.to respond_with(:success) }
    it { expect(assigns(:feedback)).to be_a(Feedback) }
  end

  describe 'POST #create' do
    before do
      post :create, params: { feedback: { message: 'I love falafels.' } }

      allow(FrontendMailer).to receive(:new_feedback)
    end

    it { is_expected.to redirect_to(feedback_thanks_url) }

    it 'sends the feedback email' do
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
