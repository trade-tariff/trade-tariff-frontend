RSpec.describe LiveIssueHelper, type: :helper do
  describe '#markdown_field' do
    subject(:markdown_field) { helper.markdown_field(markdown) }

    let(:markdown) { 'This is **bold** text.' }
    let(:expected_html) { "<p>This is <strong>bold</strong> text.</p>\n" }

    it { is_expected.to eq(expected_html) }
  end

  describe '#live_issue_from_to_date' do
    subject(:live_issue_from_to_date) { helper.live_issue_from_to_date(live_issue) }

    let(:live_issue) { build(:live_issue, date_discovered: date_discovered, date_resolved: date_resolved) }

    let(:date_discovered) { Time.zone.parse('2025-07-15') }

    context 'when date_resolved is present' do
      let(:date_resolved) { Time.zone.parse('2025-08-01') }

      it { is_expected.to eq('15 July 2025 - 1 August 2025') }
    end

    context 'when date_resolved is nil' do
      let(:date_resolved) { nil }

      it { is_expected.to eq('15 July 2025 - Present') }
    end
  end

  describe '#live_issue_status_sort_link' do
    subject(:sort_link) { Capybara.string(helper.live_issue_status_sort_link(sort_direction)) }

    context 'when the status column is sorted ascending' do
      let(:sort_direction) { 'asc' }

      it 'links to the descending sort direction' do
        expect(sort_link).to have_link(href: live_issues_path(sort: 'desc'))
      end

      it 'shows the status label' do
        expect(sort_link).to have_link('Status', href: live_issues_path(sort: 'desc'))
      end

      it 'shows the ascending arrow' do
        expect(sort_link).to have_css('span[aria-hidden="true"]', text: '↑')
      end

      it 'shows the ascending helper text' do
        expect(sort_link).to have_css('.govuk-visually-hidden', text: 'sorted ascending')
      end
    end

    context 'when the status column is sorted descending' do
      let(:sort_direction) { 'desc' }

      it 'links to the ascending sort direction' do
        expect(sort_link).to have_link(href: live_issues_path(sort: 'asc'))
      end

      it 'shows the descending arrow' do
        expect(sort_link).to have_css('span[aria-hidden="true"]', text: '↓')
      end

      it 'shows the descending helper text' do
        expect(sort_link).to have_css('.govuk-visually-hidden', text: 'sorted descending')
      end
    end
  end
end
