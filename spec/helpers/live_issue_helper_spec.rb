RSpec.describe LiveIssueHelper, type: :helper do
  describe '#markdown_field' do
    subject(:markdown_field) { helper.markdown_field(markdown) }

    let(:markdown) { 'This is **bold** text.' }
    let(:expected_html) { "<p>This is <strong>bold</strong> text.</p>\n" }

    it { is_expected.to eq(expected_html) }

    context 'with unsafe html' do
      let(:markdown) { '<script>alert(1)</script><a href="javascript:alert(1)" onclick="alert(1)">bad</a>' }

      it 'sanitizes the output', :aggregate_failures do
        expect(markdown_field).not_to include('<script>')
        expect(markdown_field).not_to include('javascript:')
        expect(markdown_field).not_to include('onclick')
      end
    end
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

  describe '#live_issue_updated_at' do
    subject(:live_issue_updated_at) { helper.live_issue_updated_at(live_issue) }

    let(:live_issue) { build(:live_issue, updated_at:) }

    context 'when updated_at is present' do
      let(:updated_at) { Time.zone.parse('2026-02-13') }

      it { is_expected.to eq('13 February 2026') }
    end

    context 'when updated_at is missing' do
      let(:updated_at) { nil }

      it { is_expected.to eq('Not available') }
    end
  end

  describe '#live_issue_sort_label' do
    it 'labels newest-first sorting' do
      expect(helper.live_issue_sort_label('updated_desc')).to eq('Last updated (newest)')
    end

    it 'labels oldest-first sorting' do
      expect(helper.live_issue_sort_label('updated_asc')).to eq('Last updated (oldest)')
    end

    it 'falls back to newest-first sorting for unknown values' do
      expect(helper.live_issue_sort_label('sideways')).to eq('Last updated (newest)')
    end
  end

  describe '#live_issue_status_filter_label' do
    it 'labels active issue filters' do
      expect(helper.live_issue_status_filter_label('active')).to eq('Active')
    end

    it 'labels resolved issue filters' do
      expect(helper.live_issue_status_filter_label('resolved')).to eq('Resolved')
    end
  end

  describe '#live_issue_status_filter_selected?' do
    it 'returns true when the status is selected' do
      expect(helper.live_issue_status_filter_selected?(%w[active], 'active')).to be(true)
    end

    it 'returns false when the status is not selected' do
      expect(helper.live_issue_status_filter_selected?(%w[resolved], 'active')).to be(false)
    end
  end

  describe '#live_issue_active_filter_labels' do
    it 'includes sort and status labels' do
      expect(
        helper.live_issue_active_filter_labels(
          status_filters: %w[active],
          sort: 'updated_desc',
        ),
      ).to eq([
        'Sort by: Last updated (newest)',
        'Status: Active issue',
      ])
    end

    it 'omits the sort label when no sort has been applied' do
      expect(
        helper.live_issue_active_filter_labels(
          status_filters: %w[resolved],
          sort: nil,
        ),
      ).to eq(['Status: Issue resolved'])
    end
  end

  describe '#live_issue_status_label' do
    it 'labels active issues' do
      expect(helper.live_issue_status_label('Active')).to eq('Active issue')
    end

    it 'labels resolved issues' do
      expect(helper.live_issue_status_label('Resolved')).to eq('Issue resolved')
    end
  end

  describe '#live_issue_status_tag_class' do
    it 'uses a yellow tag for active issues' do
      expect(helper.live_issue_status_tag_class('Active')).to eq('govuk-tag--yellow')
    end

    it 'uses a green tag for resolved issues' do
      expect(helper.live_issue_status_tag_class('Resolved')).to eq('govuk-tag--green')
    end
  end
end
