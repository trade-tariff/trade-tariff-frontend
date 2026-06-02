require 'spec_helper'

RSpec.describe GovukFrontendHelper, type: :helper do
  describe '#contents_list_item' do
    subject { contents_list_item 'Some link', '#some-link' }

    it { is_expected.to have_css 'li.gem-c-contents-list__list-item' }
    it { is_expected.to have_css 'li.gem-c-contents-list__list-item--dashed' }
    it { is_expected.to have_css 'li a.gem-c-contents-list__link' }
    it { is_expected.to have_link 'Some link', href: '#some-link' }

    context 'with custom link classes' do
      subject { contents_list_item 'Some link', '#some-link', 'some-custom-class' }

      it { is_expected.to have_css 'li a.gem-c-contents-list__link.some-custom-class' }
    end

    context 'with custom url generation' do
      subject do
        contents_list_item('Some link', { id: 10 }) { |item| "/page/#{item[:id]}" }
      end

      it { is_expected.to have_link 'Some link', href: '/page/10' }
    end
  end

  describe '#back_to_top_link' do
    subject { back_to_top_link }

    it { is_expected.to have_link 'Back to top', href: '#content' }
    it { is_expected.to have_css 'a.govuk-\!-display-none-print' }
  end

  describe '#contents_list' do
    subject { contents_list list }

    let :list do
      [
        ['First section', '#section1'],
        ['Second section', '#section2'],
        ['Third section', '#section3'],
      ]
    end

    it { is_expected.to have_css 'nav.gem-c-contents-list' }
    it { is_expected.to have_css 'nav h2.gem-c-contents-list__title', text: 'Contents' }
    it { is_expected.to have_css 'nav ol.gem-c-contents-list__list li a', count: 3 }
    it { is_expected.to have_link 'Second section', href: '#section2' }

    context 'without title' do
      subject { contents_list list, title: false }

      it { is_expected.not_to have_css 'h2' }
    end

    context 'with custom title' do
      subject { contents_list list, title: 'List title' }

      it { is_expected.to have_css 'h2', text: 'List title' }
    end

    context 'with extra nav classes' do
      subject { contents_list list, classes: 'another' }

      it { is_expected.to have_css 'nav.gem-c-contents-list.another' }
    end

    context 'with extra nav params' do
      subject { contents_list list, role: 'testing' }

      it { is_expected.to have_css 'nav[role="testing"]' }
    end

    context 'with extra list item classes' do
      subject { contents_list list, item_classes: 'listitem' }

      it { is_expected.to have_css 'nav ol li a.listitem' }
    end

    context 'with custom link generation' do
      subject { contents_list(list) { |item| item.gsub '#', '/page/' } }

      it { is_expected.to have_link 'First section', href: '/page/section1' }
    end
  end

  describe '#app_filter' do
    subject(:filter) { Capybara.string(rendered_filter) }

    let(:rendered_filter) do
      app_filter(
        title: 'Filter and sort',
        action: '/live_issues',
        result_count: '20 results',
        clear_path: '/live_issues',
        selected_filters: [
          { label: 'Sort by: Last updated (oldest)', remove_path: '/live_issues?status%5B%5D=active' },
          { label: 'Status: Active issue', remove_path: '/live_issues?sort=updated_asc' },
        ],
        selected_filters_heading: 'Active filters and sorting',
        submit_text: 'Apply',
        clear_text: 'Clear all',
        classes: 'live-issues__filter-panel',
      ) do
        tag.div('Filter controls', class: 'filter-controls')
      end
    end

    it 'renders a GOV.UK details filter panel with count and form content', :aggregate_failures do
      expect(filter).to have_css('details.app-c-filter.live-issues__filter-panel')
      expect(filter).to have_css('summary', text: 'Filter and sort')
      expect(filter).to have_css('.app-c-filter__count', text: '20 results')
      expect(filter).to have_css('form[action="/live_issues"][method="get"] .filter-controls', text: 'Filter controls')
      expect(filter).to have_button('Apply')
    end

    it 'renders selected filter remove links and clear action', :aggregate_failures do
      expect(filter).to have_css('.app-c-selected-filters h2', text: 'Active filters and sorting')
      expect(filter).to have_link('Sort by: Last updated (oldest)', href: '/live_issues?status%5B%5D=active')
      expect(filter).to have_link('Status: Active issue', href: '/live_issues?sort=updated_asc')
      expect(filter).to have_css('.app-c-selected-filters__tag span[aria-hidden="true"]', text: '×', count: 2)
      expect(filter).to have_css('.govuk-visually-hidden', text: 'Remove this filter:', count: 2)
      expect(filter).to have_link('Clear all', href: '/live_issues')
    end
  end

  describe '#utf16_code_units_length' do
    it 'counts simple ASCII correctly' do
      expect(described_class.utf16_code_units_length('abc')).to eq(3)
    end

    it 'normalises CRLF newlines to LF and counts them as one' do
      str = "a\r\nb\r\nc"
      expect(described_class.utf16_code_units_length(str)).to eq(5) # "a\nb\nc"
    end

    it 'counts emoji (outside BMP) as 2 code units each' do
      str = 'a💩b' # "💩" is U+1F4A9
      expect(described_class.utf16_code_units_length(str)).to eq(4) # "a"(1) + "💩"(2) + "b"(1)
    end

    it 'counts multiple lines with mixed endings consistently' do
      str = "line1\r\nline2\nline3\rline4"
      normalized = "line1\nline2\nline3\nline4"
      expect(described_class.utf16_code_units_length(str)).to eq(normalized.length)
    end
  end
end
