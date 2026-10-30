require 'spec_helper'

RSpec.describe 'layouts/application', type: :view do
  subject { render }

  before do
    allow(view).to receive(:is_switch_service_banner_enabled?).and_return true

    assign :search, Search.new
  end

  it { is_expected.to have_css 'header.govuk-header .govuk-width-container > .tariff-header-banner' }

  describe 'the sign-in link' do
    it 'links to the subscriptions start page when the user is not signed in' do
      render

      expect(rendered).to have_link(
        'Sign in',
        href: '/subscriptions/start',
      )
    end

    it 'tracks sign-in clicks' do
      render

      expect(rendered).to have_css('#header-sign-in-link[data-controller="analytics"][data-action="click->analytics#track"][data-analytics-event="header_sign_in_clicked"]')
    end

    it 'places the sign-in link in the service navigation row', :aggregate_failures do
      render

      expect(rendered).to have_css('.app-service-navigation #header-sign-in-link.govuk-\\!-display-none-print')
      expect(rendered).not_to have_css('.govuk-header #header-sign-in-link')
    end

    it 'adds the current page to the sign-in analytics context' do
      render

      expect(JSON.parse(Capybara.string(rendered).find('#header-sign-in-link')[:'data-analytics-context-value']))
        .to eq('page_path' => request.path)
    end

    it 'links to subscriptions when the user has an ID token' do
      cookies[TradeTariffFrontend.id_token_cookie_name] = 'token'

      render

      expect(rendered).to have_link(
        'Sign in',
        href: '/subscriptions',
      )
    end

    context 'when the current page has a search date' do
      before do
        allow(view).to receive(:params).and_return(
          ActionController::Parameters.new(day: '1', month: '11', year: '2026'),
        )
      end

      it 'does not carry the search date into the sign-in link' do
        render

        expect(rendered).to have_link('Sign in', href: '/subscriptions/start')
      end
    end
  end

  it 'renders the feedback invitation', :aggregate_failures do
    render

    expect(rendered).to have_css('.govuk-feedback')
    expect(rendered).to have_css('.govuk-feedback__title', text: 'Help us improve this service')
    expect(rendered).to have_text('Tell us about your experience using this service.')
    expect(rendered).to have_link('Give us your feedback', href: %r{\A/feedback\?})
  end

  it 'preserves search context in the enquiry link' do
    assign :search, Search.new(request_id: 'search-request-123')

    render

    expect(rendered).to have_link('Enquiry Form', href: '/enquiry_form?request_id=search-request-123')
  end

  context 'when rendering an interactive search page' do
    before { assign(:interactive_search_page, true) }

    it 'uses the feedback invitation', :aggregate_failures do
      render

      expect(rendered).to have_css('.govuk-feedback')
      expect(rendered).not_to have_text('Is this page useful?')
    end
  end

  it 'opts stylesheet tags out of preload link headers' do
    stylesheet_link_calls = []

    allow(view).to receive(:stylesheet_link_tag).and_wrap_original do |method, *args, **kwargs|
      stylesheet_link_calls << [args, kwargs]
      method.call(*args, **kwargs)
    end

    render

    expect(stylesheet_link_calls).to include(
      [[:application], { 'data-turbo-track': 'reload', preload_links_header: false }],
      [[:print], { media: 'print', 'data-turbo-track': 'reload', preload_links_header: false }],
    )
  end

  describe 'AWS WAF integration script' do
    before do
      allow(view).to receive(:content_security_policy_nonce).and_return('test-nonce')
    end

    context 'when the WAF integration is enabled' do
      before do
        allow(TradeTariffFrontend).to receive_messages(waf_integration_enabled?: true, waf_integration_url: 'https://waf.example.com/abc')
      end

      # The CSP uses 'strict-dynamic', so a script without the page nonce is a
      # violation, and every page load sent a CSP report.
      it 'adds the CSP nonce to the challenge script' do
        render

        expect(rendered).to have_css('script[src="https://waf.example.com/abc/challenge.js"][nonce="test-nonce"]', visible: :all)
      end
    end

    context 'when the WAF integration is disabled' do
      before do
        allow(TradeTariffFrontend).to receive(:waf_integration_enabled?).and_return(false)
      end

      it 'does not add the challenge script' do
        render

        expect(rendered).not_to have_css('script[src$="/challenge.js"]', visible: :all)
      end
    end
  end
end
