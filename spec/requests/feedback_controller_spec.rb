require 'spec_helper'

RSpec.describe FeedbackController, type: :request do
  subject { response }

  describe 'GET #new' do
    before { get new_feedback_path }

    it { is_expected.to have_http_status :success }
  end

  describe 'POST #create' do
    before { post feedbacks_path, params: }

    let(:params) do
      {
        feedback: { message: 'I love falafels.' },
        authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
      }
    end

    it { is_expected.to redirect_to(feedback_thanks_url) }

    it 'sends the feedback email' do
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end
end
