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

  describe 'feedback from POST search results' do
    let(:message) { 'Search feedback with context' }
    let(:authenticity_token) { 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw' }

    before do
      stub_api_request('search', :post).to_return(
        jsonapi_response(:search, {
          type: 'fuzzy_match',
          goods_nomenclature_match: { chapters: [], headings: [], commodities: [], sections: [] },
          reference_match: { chapters: [], headings: [], commodities: [], sections: [] },
        }),
      )
    end

    it 'sends the search URL, query, request id and date of trade to support when the URL has no query param', :aggregate_failures do
      post perform_search_path, params: { q: 'leather handbags', request_id: 'search-request-123', day: '5', month: '6', year: '2026' }

      expect(response).to have_http_status(:ok)
      expect(request.original_url).to eq('http://www.example.com/search')

      feedback_hrefs = Nokogiri::HTML(response.body)
                              .css('a[href^="/feedback?"]')
                              .map { |link| link['href'] }

      expect(feedback_hrefs).not_to be_empty
      feedback_hrefs.each do |href|
        feedback_params = Rack::Utils.parse_query(URI.parse(href).query)

        expect(feedback_params).to include(
          'feedback_url' => 'http://www.example.com/search',
          'feedback_query' => 'leather handbags',
          'feedback_request_id' => 'search-request-123',
          'feedback_date' => '2026-06-05',
        )
      end

      get feedback_hrefs.first
      post feedbacks_path, params: {
        feedback: { message: },
        authenticity_token:,
      }

      email_body = ActionMailer::Base.deliveries.last.body.to_s

      expect(email_body).to include('URL: http://www.example.com/search')
      expect(email_body).to include('Query: leather handbags')
      expect(email_body).to include('Request ID: search-request-123')
      expect(email_body).to include('Date of trade: 2026-06-05')
    end
  end
end
