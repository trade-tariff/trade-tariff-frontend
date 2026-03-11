require 'spec_helper'

RSpec.describe FeedbackController, type: :request do
  subject { response }

  let(:message) { 'This message is valid.' }

  describe 'GET #new' do
    before { get new_feedback_path }

    it { is_expected.to have_http_status :success }

    context 'with HTTP_REFERER set' do
      before do
        get new_feedback_path, headers: { 'HTTP_REFERER' => 'http://test.host/404' }
        post feedbacks_path, params: {
          feedback: { message: },
          authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
        }
        follow_redirect!
      end

      it 'shows the thanks page with Return to page link' do
        expect(response.body).to include('Return to page')
      end

      it 'links Return to page at the referrer URL' do
        expect(response.body).to include('http://test.host/404')
      end
    end
  end

  describe 'POST #create' do
    before { post feedbacks_path, params: }

    let(:params) do
      {
        feedback: { message: },
        authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
      }
    end

    it { is_expected.to redirect_to(feedback_thanks_url) }

    it 'sends the feedback email' do
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end

    context 'when honeypot (telephone field) captcha data included' do
      let(:params) do
        {
          feedback: { message:,
                      telephone: '00000000000' },
          authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
        }
      end

      it { is_expected.not_to redirect_to(feedback_thanks_url) }

      it 'does not send the email' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end

    context 'when valid feedback useful choice' do
      let(:params) do
        {
          feedback: { message:,
                      page_useful: 'yes' },
          authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
        }
      end

      it { is_expected.to redirect_to(feedback_thanks_url) }

      it 'sends the feedback email' do
        expect(ActionMailer::Base.deliveries.count).to eq(1)
      end

      it 'includes users selected choice in the email' do
        expect(ActionMailer::Base.deliveries.last.body).to include('Found this page useful: yes')
      end
    end

    context 'when invalid feedback useful choice' do
      let(:params) do
        {
          feedback: { message:,
                      page_useful: 'invalid' },
          authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
        }
      end

      it { is_expected.to redirect_to(find_commodity_url) }

      it 'does not send the email' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end

    context 'when feedback message contains integers only' do
      let(:params) do
        {
          feedback: { message: '1234567890' },
          authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
        }
      end

      it { is_expected.to redirect_to(feedback_thanks_url) }

      it 'does not send the email' do
        expect(ActionMailer::Base.deliveries.count).to eq(0)
      end
    end
  end
end
