require 'spec_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#home_path' do
    subject(:home_path) { helper.home_path }

    it { is_expected.to eq(find_commodity_path) }
  end

  describe '#home_url' do
    subject(:home_url) { helper.home_url }

    it { is_expected.to eq(find_commodity_url) }
  end

  describe '#govspeak' do
    subject(:html) { govspeak source }

    context 'with string without HTML code' do
      let(:source) { '**hello**' }

      it { is_expected.to have_css 'p strong', text: 'hello' }
    end

    context 'when string contains Javascript code' do
      let(:source) { "<script type='text/javascript'>alert('hello');</script>" }

      it { is_expected.to be_blank }
    end

    context 'when HashWithIndifferentAccess is passed as argument' do
      let(:source) { { 'content' => '* 1\\. This chapter does not cover:' } }

      it { is_expected.to have_css 'ul li', text: '1. This chapter does not cover:' }
    end

    context 'when HashWithIndifferentAccess is passed as argument with no applicable content' do
      let(:source) { { 'foo' => 'bar' } }

      it { is_expected.to be_blank }
    end

    context 'with link with target attribute' do
      let(:source) { %(<a href="/" target="_blank">/</a>) }

      it { is_expected.to have_css 'p a[href="/"][target="_blank"]', text: '' }
    end

    context 'with table' do
      let :source do
        <<~EOSOURCE
          Hello

          | Heading A | Heading B |
          | --------- | --------- |
          | Column A  | Column B  |

          World
        EOSOURCE
      end

      it { is_expected.to have_css 'div.scroll-x table thead tr th', count: 2 }
      it { is_expected.to have_css 'div.scroll-x table tbody tr td', count: 2 }
    end
  end

  describe '.generate_breadcrumbs' do
    context 'with single page' do
      subject { generate_breadcrumbs 'Current Page', [] }

      it { is_expected.to have_css 'nav.govuk-breadcrumbs[aria-label="Breadcrumb"]' }
      it { is_expected.to have_css 'nav ol.govuk-breadcrumbs__list' }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item', count: 1 }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item a.govuk-breadcrumbs__link', count: 0 }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item', text: 'Current Page' }
    end

    context 'with nested pages' do
      subject { generate_breadcrumbs 'Current Page', [['Previous Page', '/']] }

      it { is_expected.to have_css 'nav.govuk-breadcrumbs[aria-label="Breadcrumb"]' }
      it { is_expected.to have_css 'nav ol.govuk-breadcrumbs__list' }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item', count: 2 }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item a.govuk-breadcrumbs__link', count: 1 }
      it { is_expected.to have_css 'ol li.govuk-breadcrumbs__list-item', text: 'Current Page' }
      it { is_expected.to have_link 'Previous Page', href: '/' }
    end
  end

  describe '#breadcrumb_link_or_text' do
    context 'when the breadcrumb item is the last one' do
      it 'returns plain text' do
        breadcrumb_item = breadcrumb_link_or_text('AAA', nil, 'Link description')

        expect(breadcrumb_item).to eq('Link description')
      end
    end

    context 'when the breadcrumb item is NOT the last one' do
      it 'returns a link (which allows to go back)' do
        breadcrumb_item = breadcrumb_link_or_text('AAA', 'BBB', 'Link description')

        expect(breadcrumb_item).to eq('<a class="govuk-breadcrumbs__link" href="AAA">Link description</a>')
      end
    end
  end

  describe '#service_navigation_active_when' do
    subject(:active_when_pattern) { helper.service_navigation_active_when(*prefixes) }

    let(:prefixes) { %w[search find_commodity] }

    it { expect(active_when_pattern).to be_a(Regexp) }
    it { expect(active_when_pattern).to match('/search') }
    it { expect(active_when_pattern).to match('/find_commodity') }
    it { expect(active_when_pattern).to match('/xi/search') }
    it { expect(active_when_pattern).to match('/uk/find_commodity') }
    it { expect(active_when_pattern).not_to match('/browse') }
  end

  describe '#page_header' do
    before do
      allow(helper).to receive(:is_switch_service_banner_enabled?)
                         .and_return switch_banner
    end

    let(:switch_banner) { true }

    context 'without block' do
      subject { helper.page_header 'Test header' }

      it { is_expected.to have_css 'header span.govuk-caption-xl', text: I18n.t('title.service_name.uk') }
      it { is_expected.to have_css 'header h1.govuk-heading-l', text: 'Test header' }
      it { is_expected.to have_css 'header > *', count: 2 }
      it { is_expected.to have_css 'header span.switch-service-control' }
    end

    context 'with block' do
      subject { helper.page_header('Second header') { tag.em 'additional content' } }

      it { is_expected.to have_css 'header span.govuk-caption-xl', text: I18n.t('title.service_name.uk') }
      it { is_expected.to have_css 'header h1.govuk-heading-l', text: 'Second header' }
      it { is_expected.to have_css 'header > *', count: 3 }
      it { is_expected.to have_css 'header span.switch-service-control' }
      it { is_expected.to have_css 'header em', text: 'additional content' }
    end

    context 'with XI service' do
      subject { helper.page_header 'Test header' }

      include_context 'with XI service'

      it { is_expected.to have_css 'header span.govuk-caption-xl', text: I18n.t('title.service_name.xi') }
    end

    context 'with switch banner disabled' do
      let(:switch_banner) { false }

      it { is_expected.not_to have_css 'span.switch-service-control' }
    end

    context 'with caption' do
      subject { helper.page_header 'Some header', 'Some caption' }

      it { is_expected.to have_css 'header h1.govuk-heading-l', text: 'Some header' }
      it { is_expected.to have_css 'header span.govuk-caption-xl', text: 'Some caption' }
    end

    context 'with false caption' do
      subject { helper.page_header 'Some header', false }

      it { is_expected.to have_css 'header h1.govuk-heading-l', text: 'Some header' }
      it { is_expected.not_to have_css 'header span.govuk-caption-xl' }
    end
  end

  describe '#css_heading_size' do
    subject { helper.css_heading_size(text) }

    context 'when text length is greater than or equal to 400 chars' do
      let(:text) { 'X' * 400 }

      it { is_expected.to eq 'govuk-heading-s' } # Small text
    end

    context 'when text length is between 120 and 400 chars' do
      let(:text) { 'X' * 150 }

      it { is_expected.to eq 'govuk-heading-m' } # Medium text
    end

    context 'when text length is smaller than 120 chars' do
      let(:text) { 'X' * 119 }

      it { is_expected.to eq 'govuk-heading-l' } # Large text
    end
  end

  describe '#present_from_to' do
    shared_examples_for 'a from to expression' do |expected_expression, start_date, end_date|
      subject(:from_to) { helper.present_from_to(from, to) }

      let(:from) { start_date && Date.parse(start_date) }
      let(:to) { end_date && Date.parse(end_date) }

      it { is_expected.to eq(expected_expression) }
    end

    it_behaves_like 'a from to expression', ' From 1 Jan 2022 to 1 Feb 2023', '2022-01-01', '2023-02-01'
    it_behaves_like 'a from to expression', ' From 1 Jan 2022', '2022-01-01', nil
    it_behaves_like 'a from to expression', nil, nil, '2023-02-01'
    it_behaves_like 'a from to expression', nil, nil, nil
  end

  describe '#govuk_date_range' do
    let(:from) { Date.parse('2022-01-01') }
    let(:to) { Date.parse('2022-06-01') }

    context 'with TimeWithZone' do
      subject { govuk_date_range from.in_time_zone, to.in_time_zone }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'with String Dates' do
      subject { govuk_date_range from.to_fs, to.to_fs }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'with String Dates with Times' do
      subject { govuk_date_range "#{from.to_fs} 01:01:00", "#{to.to_fs} 01:02:00" }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'with XML Time Strings' do
      subject { govuk_date_range from.xmlschema, to.xmlschema }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'with Dates' do
      subject { govuk_date_range from, to }

      it { is_expected.to eql '1 January 2022 to 1 June 2022' }
    end

    context 'when :to date is blank' do
      subject { govuk_date_range from, '' }

      it { is_expected.to eql 'From 1 January 2022' }
    end

    context 'when :to date is nil' do
      subject { govuk_date_range from, nil }

      it { is_expected.to eql 'From 1 January 2022' }
    end
  end

  describe '#paragraph_if_content' do
    subject { paragraph_if_content content }

    context 'with content' do
      let(:content) { 'this is some <em>content</em>'.html_safe }

      it { is_expected.to have_css 'p', text: /this is some/ }
      it { is_expected.to have_css 'p em', text: 'content' }
    end

    context 'with nil' do
      let(:content) { nil }

      it { is_expected.to be_nil }
    end

    context 'with blank string' do
      let(:content) { '' }

      it { is_expected.to be_nil }
    end
  end

  describe '#back_link' do
    context 'without javascript' do
      it 'calls govuk_back_link with correct attributes' do
        allow(helper).to receive(:govuk_back_link).with(href: '/back-page', html_attributes: {}).and_call_original

        result = helper.back_link('/back-page')

        expect(result).to be_present
      end
    end

    context 'with javascript' do
      it 'calls govuk_back_link with onclick attribute' do
        allow(helper).to receive(:govuk_back_link).with(href: '/back', html_attributes: { onclick: 'window.history.go(-1); return false;' }).and_call_original

        result = helper.back_link('/back', javascript: true)

        expect(result).to be_present
      end
    end
  end

  describe '#glossary_term' do
    subject { glossary_term 'MaxNOM' }

    it { is_expected.to have_link 'MaxNOM', href: '/glossary/max_nom' }
  end

  describe 'link_glossary_terms' do
    subject { link_glossary_terms content }

    before { allow(Pages::Glossary).to receive(:terms).and_return %w[max_nom rvc] }

    context 'with matching term' do
      let(:content) { 'Some content (MaxNOM)' }

      it { is_expected.to eql 'Some content ([MaxNOM](/glossary/max_nom))' }
    end

    context 'without matching term' do
      let(:content) { 'Some content (NOM)' }

      it { is_expected.to eql content }
    end

    context 'with multiple terms' do
      let(:content) { 'Some (RVC) content (MaxNOM)' }

      it { is_expected.to eql 'Some ([RVC](/glossary/rvc)) content ([MaxNOM](/glossary/max_nom))' }
    end
  end

  describe '#feedback_context_params' do
    context 'when not on the feedback controller' do
      before do
        allow(helper.request).to receive(:original_url).and_return('http://test.host/commodities/1234567890')
        controller.params[:q] = 'leather handbags'
      end

      it 'derives feedback_url from the current page URL' do
        expect(helper.feedback_context_params).to include(feedback_url: 'http://test.host/commodities/1234567890')
      end

      it 'includes enabled feature flags' do
        allow(TradeTariffFrontend).to receive(:enabled_flagsmith_feature_names)
          .and_return(%w[interactive_search webchat])

        expect(helper.feedback_context_params).to include(
          feedback_feature_flags: 'interactive_search,webchat',
        )
      end

      it 'includes an explicit empty feature flag context' do
        allow(TradeTariffFrontend).to receive(:enabled_flagsmith_feature_names).and_return([])

        expect(helper.feedback_context_params).to include(feedback_feature_flags: '')
      end
    end

    context 'when already on the feedback controller' do
      before do
        allow(helper.controller).to receive(:controller_path).and_return('feedback')
        controller.params[:feedback_url] = 'http://test.host/commodities/1234567890'
        controller.params[:feedback_query] = 'leather handbags'
      end

      it 'passes through the existing feedback_url instead of the current (feedback) page URL' do
        expect(helper.feedback_context_params).to eq(
          feedback_url: 'http://test.host/commodities/1234567890',
          feedback_query: 'leather handbags',
        )
      end

      it 'ignores request.original_url so the feedback page cannot nest itself into feedback_url' do
        allow(helper.request).to receive(:original_url)
          .and_return('http://test.host/feedback?feedback_url=http://test.host/commodities/1234567890')

        expect(helper.feedback_context_params[:feedback_url]).not_to include('/feedback?feedback_url=')
      end
    end
  end

  describe '#enquiry_form_path_with_context' do
    subject(:path) { helper.enquiry_form_path_with_context }

    it 'includes the current search request id' do
      assign(:search, build(:search, request_id: 'search-request-123'))

      expect(path).to eq('/enquiry_form?request_id=search-request-123')
    end

    it 'falls back to the request params' do
      controller.params[:request_id] = 'search-request-456'

      expect(path).to eq('/enquiry_form?request_id=search-request-456')
    end

    it 'preserves context from the feedback page' do
      controller.params[:feedback_request_id] = 'search-request-789'

      expect(path).to eq('/enquiry_form?request_id=search-request-789')
    end

    it 'omits a missing request id' do
      expect(path).to eq('/enquiry_form')
    end
  end

  describe '#current_feedback_params' do
    it 'passes through the feedback params already on the request' do
      controller.params[:feedback_url] = 'http://test.host/commodities/1234567890'
      controller.params[:feedback_query] = 'leather handbags'
      controller.params[:feedback_request_id] = 'abc-123'
      controller.params[:feedback_date] = '2026-01-01'
      controller.params[:feedback_feature_flags] = 'interactive_search,webchat'

      expect(helper.current_feedback_params).to eq(
        feedback_url: 'http://test.host/commodities/1234567890',
        feedback_query: 'leather handbags',
        feedback_request_id: 'abc-123',
        feedback_date: '2026-01-01',
        feedback_feature_flags: 'interactive_search,webchat',
      )
    end

    it 'omits params that are not present' do
      controller.params[:feedback_url] = 'http://test.host/commodities/1234567890'

      expect(helper.current_feedback_params).to eq(feedback_url: 'http://test.host/commodities/1234567890')
    end
  end

  describe '#duty_calculator_link' do
    subject(:link) { helper.duty_calculator_link(declarable_code) }

    let(:declarable_code) { '1704909991' }

    context 'when the service is uk' do
      include_context 'with UK service'

      it { is_expected.to have_css 'a', text: 'work out the duties and taxes applicable to the import of commodity 1704 9099 91' }
      it { is_expected.to have_css 'a[href="/duty-calculator/1704909991/import-date"]' }

      context 'with a heading-level code' do
        let(:declarable_code) { '1704000000' }

        it { is_expected.to have_css 'a', text: 'work out the duties and taxes applicable to the import of commodity 1704 0000 00' }
        it { is_expected.to have_css 'a[href="/duty-calculator/1704000000/import-date"]' }
      end
    end

    context 'when the service is xi' do
      include_context 'with XI service'

      it { is_expected.to have_css 'a', text: 'work out the duties and taxes applicable to the import of commodity 1704 9099 91' }
      it { is_expected.to have_css 'a[href="/xi/duty-calculator/1704909991/import-date"]' }

      context 'with a heading-level code' do
        let(:declarable_code) { '1704000000' }

        it { is_expected.to have_css 'a', text: 'work out the duties and taxes applicable to the import of commodity 1704 0000 00' }
        it { is_expected.to have_css 'a[href="/xi/duty-calculator/1704000000/import-date"]' }
      end
    end
  end
end
