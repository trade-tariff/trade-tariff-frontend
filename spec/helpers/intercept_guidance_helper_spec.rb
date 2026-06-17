# spec/helpers/intercept_guidance_helper_spec.rb
require 'spec_helper'

RSpec.describe InterceptGuidanceHelper do
  include ApplicationHelper
  include described_class

  let(:search) { Search.new(q: 'toiletries set', request_id: 'req-abc-123') }

  describe '#resolve_intercept_placeholders' do
    it 'replaces {{request_id}} with the bold search request_id' do
      msg = 'Your reference is {{request_id}}. Please quote it.'
      expect(resolve_intercept_placeholders(msg, search:)).to eq('Your reference is **req-abc-123**. Please quote it.')
    end

    it 'replaces {{search_term}} with the original query' do
      msg = 'You searched for {{search_term}}'
      expect(resolve_intercept_placeholders(msg, search:)).to eq('You searched for toiletries set')
    end

    it 'replaces {{enquiries_email}} with the default enquiries email' do
      msg = 'Contact {{enquiries_email}} for help.'
      allow(TradeTariffFrontend).to receive(:enquiries_email).and_return('classification.enquiries@hmrc.gov.uk')

      expect(resolve_intercept_placeholders(msg, search:)).to eq('Contact classification.enquiries@hmrc.gov.uk for help.')
    end

    it 'replaces {{webchat_url}} with the configured webchat URL' do
      msg = '[Ask HMRC online]({{webchat_url}})'
      allow(TradeTariffFrontend).to receive(:webchat_url).and_return('https://example.com/webchat')

      expect(resolve_intercept_placeholders(msg, search:)).to eq('[Ask HMRC online](https://example.com/webchat)')
    end

    it 'leaves unknown placeholders untouched' do
      msg = 'Contact {{unknown_email}} for help.'
      expect(resolve_intercept_placeholders(msg, search:)).to eq('Contact {{unknown_email}} for help.')
    end

    it 'handles multiple replacements in one message' do
      msg = 'Ref: {{request_id}} | Term: {{search_term}}'
      result = resolve_intercept_placeholders(msg, search:)
      expect(result).to eq('Ref: **req-abc-123** | Term: toiletries set')
    end
  end

  describe '#render_intercept_message' do
    it 'resolves placeholders then renders via govspeak', :aggregate_failures do
      msg = "Hello {{search_term}}\n\nReference: {{request_id}}"
      html = render_intercept_message(msg, search:)
      expect(html).to include('Hello toiletries set')
      expect(html).to include('Reference: <strong>req-abc-123</strong>')
    end

    it 'uses GOV.UK Frontend typography classes for rendered markdown', :aggregate_failures do
      html = render_intercept_message(
        "## Next steps\n\nDo this:\n\n- Contact HMRC\n\n[Ask HMRC online](https://example.com/webchat)",
        search:,
      )

      expect(html).to have_css('h2.govuk-heading-m', text: 'Next steps')
      expect(html).to have_css('p.govuk-body', text: 'Do this:')
      expect(html).to have_css('ul.govuk-list.govuk-list--bullet li', text: 'Contact HMRC')
      expect(html).to have_css('a.govuk-link[href="https://example.com/webchat"]', text: 'Ask HMRC online')
      expect(html).not_to include('style=')
    end

    it 'opens rendered markdown links in a new tab', :aggregate_failures do
      html = render_intercept_message('[Ask HMRC online](https://example.com/webchat)', search:)

      expect(html).to have_css(
        'a.govuk-link[href="https://example.com/webchat"][target="_blank"][rel~="noopener"][rel~="noreferrer"]',
        text: 'Ask HMRC online',
      )
      expect(html).not_to have_css('a .govuk-visually-hidden', text: '(opens in new tab)')
    end

    it 'linkifies goods nomenclature code references like the admin preview', :aggregate_failures do
      msg = 'Review Chapter 71, headings 3207 to 3210, subheading 8703.10 and commodity 0101210000.'
      html = render_intercept_message(msg, search:)

      expect(html).to have_css('a.govuk-link[href="/search?q=71"][target="_blank"][rel="noopener noreferrer"]', text: '71')
      expect(html).to have_css('a.govuk-link[href="/search?q=3207"]', text: '3207')
      expect(html).to have_css('a.govuk-link[href="/search?q=3210"]', text: '3210')
      expect(html).to have_css('a.govuk-link[href="/search?q=870310"]', text: '8703.10')
      expect(html).to have_css('a.govuk-link[href="/search?q=0101210000"]', text: '0101210000')
      expect(html).to have_css('a .govuk-visually-hidden', text: '(opens in new tab)', count: 5)
    end

    it 'does not linkify code references inside existing markdown links', :aggregate_failures do
      html = render_intercept_message('[Read about 0101](https://example.com/existing) and Chapter 71', search:)

      expect(html).to have_css('a.govuk-link[href="https://example.com/existing"]', text: 'Read about 0101')
      expect(html).to have_css('a.govuk-link[href="/search?q=71"]', text: '71')
      expect(html).not_to have_css('a[href="https://example.com/existing"] a')
    end
  end
end
