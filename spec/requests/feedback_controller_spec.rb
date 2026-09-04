require 'spec_helper'

RSpec.describe FeedbackController, type: :request do
  subject { response }

  let(:message) { 'This message is valid.' }

  describe 'GET #new' do
    before { get new_feedback_path }

    it { is_expected.to have_http_status :success }

    it 'captures enabled feature flags' do
      enable_feature(:webchat)

      get new_feedback_path

      feedback_form = Nokogiri::HTML(response.body)
      expect(feedback_form.at_css('input[name="feedback_feature_flags"]')['value']).to eq('webchat')
    end

    it 'preserves the search request identifier in the enquiry link' do
      get new_feedback_path(feedback_request_id: 'search-request-123')

      enquiry_link = Nokogiri::HTML(response.body).css('a').find { |link| link.text.strip == 'enquiry form' }

      expect(enquiry_link['href']).to eq(
        product_experience_enquiry_form_path(request_id: 'search-request-123'),
      )
    end

    it 'preserves a search request identifier recovered from the referrer' do
      get new_feedback_path,
          headers: { 'HTTP_REFERER' => 'http://test.host/search?request_id=search-request-456' }

      enquiry_link = Nokogiri::HTML(response.body).css('a').find { |link| link.text.strip == 'enquiry form' }

      expect(enquiry_link['href']).to eq(
        product_experience_enquiry_form_path(request_id: 'search-request-456'),
      )
    end

    context 'with HTTP_REFERER set' do
      before do
        get new_feedback_path, headers: { 'HTTP_REFERER' => 'http://test.host/404' }
        post feedbacks_path, params: {
          feedback: { message: },
          feedback_url: 'http://test.host/404',
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

  describe 'session cookie size' do
    # The session cookie is a single browser-enforced 4096-byte budget shared by every
    # feature that writes to `session` (duty calculator answers, myott preferences,
    # meursing lookups, experiment opt-ins, and so on). This controller must never spend
    # any of that budget itself, however much context a request carries, otherwise it can
    # tip an already-long cookie (from any of those other sources) over the limit.
    let(:large_context) { 'a' * 4500 }

    let(:params_with_large_context) do
      {
        feedback: { message: },
        feedback_url: large_context,
        feedback_query: large_context,
        feedback_request_id: large_context,
        feedback_date: large_context,
        feedback_feature_flags: large_context,
        authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
      }
    end

    it 'does not raise CookieOverflow, regardless of how large the request context is' do
      expect {
        get new_feedback_path, params: params_with_large_context.except(:feedback, :authenticity_token)
        post feedbacks_path, params: params_with_large_context
      }.not_to raise_error
    end

    it 'never writes feedback context into the session' do
      get new_feedback_path, params: params_with_large_context.except(:feedback, :authenticity_token)
      post feedbacks_path, params: params_with_large_context

      expect(session.to_hash.keys).not_to include(
        'feedback_referrer',
        'feedback_query',
        'feedback_request_id',
        'feedback_date',
        'feedback_feature_flags',
      )
    end

    it 'keeps the session cookie well under the browser 4096-byte limit' do
      get new_feedback_path, params: params_with_large_context.except(:feedback, :authenticity_token)
      post feedbacks_path, params: params_with_large_context

      session_cookie = response.headers['Set-Cookie'].to_s.split("\n").find { |c| c.start_with?('_tradetarifffrontend_session=') }
      expect(session_cookie.to_s.bytesize).to be < 4096
    end
  end

  describe 'self-referential feedback_url' do
    # The layout footer renders a "Feedback" link (via ApplicationHelper#feedback_context_params)
    # on every page, including the feedback page itself. If that helper always derived
    # feedback_url from the current page's own URL, visiting /feedback (which already carries
    # ?feedback_url=...) and following its own footer link would wrap the URL in another layer
    # of ?feedback_url=..., compounding indefinitely on repeated visits.
    let(:original_page) { 'http://test.host/404' }

    def footer_feedback_href
      response.body[/<a[^>]+href="([^"]+)"[^>]*>Feedback<\/a>/, 1]
    end

    before { get new_feedback_path, params: { feedback_url: original_page } }

    it 'points the footer feedback link at the original page' do
      expect(Rack::Utils.parse_query(URI.parse(footer_feedback_href).query)).to eq('feedback_url' => original_page)
    end

    it 'does not grow the link when following it from the feedback page itself' do
      first_href = footer_feedback_href
      get first_href

      expect(footer_feedback_href).to eq(first_href)
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

    it 'reports when no feature flags were enabled' do
      expect(ActionMailer::Base.deliveries.last.body).to include('Feature flags: None')
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

    context 'with unknown feature flags' do
      let(:params) do
        {
          feedback: { message: },
          feedback_feature_flags: 'interactive_search,unknown_feature',
          authenticity_token: 'YZDyyHGMqRyXH1ALc0-helPFpCAcUgdyGlErrPgbtvwYxK4ftq6t2xNcfgoknWADYZY9zxncvyiZhvFPTS-irw',
        }
      end

      it 'omits unregistered names' do
        email = Nokogiri::HTML(ActionMailer::Base.deliveries.last.body.to_s)
        feature_flags = email.css('p').find { |paragraph| paragraph.text.start_with?('Feature flags:') }

        expect(feature_flags.text).to eq('Feature flags: interactive_search')
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

    it 'sends the search and feature flag context to support when the URL has no query param', :aggregate_failures do
      enable_feature(:interactive_search)
      enable_feature(:webchat)
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
          'feedback_feature_flags' => 'interactive_search,webchat',
        )
      end

      get feedback_hrefs.first

      feedback_form = Nokogiri::HTML(response.body)
      expect(feedback_form.at_css('input[name="feedback_feature_flags"]')['value']).to eq('interactive_search,webchat')

      post feedbacks_path, params: {
        feedback: { message: },
        feedback_url: 'http://www.example.com/search',
        feedback_query: 'leather handbags',
        feedback_request_id: 'search-request-123',
        feedback_date: '2026-06-05',
        feedback_feature_flags: 'interactive_search,webchat',
        authenticity_token:,
      }

      email_body = ActionMailer::Base.deliveries.last.body.to_s

      expect(email_body).to include('URL: http://www.example.com/search')
      expect(email_body).to include('Query: leather handbags')
      expect(email_body).to include('Search request ID: search-request-123')
      expect(email_body).to include('Date of trade: 2026-06-05')
      expect(email_body).to include('Feature flags: interactive_search, webchat')
    end
  end
end
