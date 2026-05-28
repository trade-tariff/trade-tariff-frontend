RSpec.describe LiveIssue do
  describe '.filtered' do
    let(:resolved_newer) { build(:live_issue, title: 'Resolved newer', status: 'Resolved', updated_at: '2025-07-16T12:00:00Z') }
    let(:active_older) { build(:live_issue, title: 'Active older', status: 'Active', updated_at: '2025-07-14T12:00:00Z') }
    let(:resolved_older) { build(:live_issue, title: 'Resolved older', status: 'Resolved', updated_at: '2025-07-13T12:00:00Z') }
    let(:active_newer) { build(:live_issue, title: 'Active newer', status: 'Active issue', updated_at: '2025-07-15T12:00:00Z') }
    let(:active_without_timestamp) { build(:live_issue, title: 'Active without timestamp', status: 'Active', updated_at: nil) }
    let(:live_issues) do
      [
        resolved_newer,
        active_older,
        resolved_older,
        active_newer,
        active_without_timestamp,
      ]
    end

    before do
      allow(described_class).to receive(:all).and_return(live_issues)
    end

    it 'sorts by last updated newest first by default' do
      expect(described_class.filtered(statuses: [], sort: nil).map(&:title)).to eq([
        'Resolved newer',
        'Active newer',
        'Active older',
        'Resolved older',
        'Active without timestamp',
      ])
    end

    it 'sorts by last updated oldest first' do
      expect(described_class.filtered(statuses: [], sort: 'updated_asc').map(&:title)).to eq([
        'Resolved older',
        'Active older',
        'Active newer',
        'Resolved newer',
        'Active without timestamp',
      ])
    end

    it 'filters active issues' do
      expect(described_class.filtered(statuses: %w[active], sort: nil).map(&:title)).to eq([
        'Active newer',
        'Active older',
        'Active without timestamp',
      ])
    end

    it 'filters resolved issues' do
      expect(described_class.filtered(statuses: %w[resolved], sort: nil).map(&:title)).to eq([
        'Resolved newer',
        'Resolved older',
      ])
    end

    it 'returns all issues when all supported statuses are selected' do
      expect(described_class.filtered(statuses: %w[active resolved], sort: nil).map(&:title)).to eq([
        'Resolved newer',
        'Active newer',
        'Active older',
        'Resolved older',
        'Active without timestamp',
      ])
    end

    it 'ignores unsupported statuses' do
      expect(described_class.filtered(statuses: %w[archived], sort: nil).map(&:title)).to eq([
        'Resolved newer',
        'Active newer',
        'Active older',
        'Resolved older',
        'Active without timestamp',
      ])
    end

    it 'falls back to newest first for unsupported sorts' do
      expect(described_class.filtered(statuses: [], sort: 'sideways').map(&:title)).to eq([
        'Resolved newer',
        'Active newer',
        'Active older',
        'Resolved older',
        'Active without timestamp',
      ])
    end
  end

  describe '.sorted_by_status' do
    let(:resolved_newer) { build(:live_issue, title: 'Resolved newer', status: 'Resolved', updated_at: '2025-07-16T12:00:00Z') }
    let(:active_older) { build(:live_issue, title: 'Active older', status: 'Active', updated_at: '2025-07-14T12:00:00Z') }
    let(:resolved_older) { build(:live_issue, title: 'Resolved older', status: 'Resolved', updated_at: '2025-07-13T12:00:00Z') }
    let(:active_newer) { build(:live_issue, title: 'Active newer', status: 'Active', updated_at: '2025-07-15T12:00:00Z') }
    let(:active_without_timestamp) { build(:live_issue, title: 'Active without timestamp', status: 'Active', updated_at: nil) }
    let(:live_issues) do
      [
        resolved_newer,
        active_older,
        resolved_older,
        active_newer,
        active_without_timestamp,
      ]
    end

    before do
      allow(described_class).to receive(:all).and_return(live_issues)
    end

    it 'sorts active issues first and updated_at descending within each status for ascending sort' do
      expect(described_class.sorted_by_status('asc').map(&:title)).to eq([
        'Active newer',
        'Active older',
        'Active without timestamp',
        'Resolved newer',
        'Resolved older',
      ])
    end

    it 'sorts active issues last and updated_at descending within each status for descending sort' do
      expect(described_class.sorted_by_status('desc').map(&:title)).to eq([
        'Resolved newer',
        'Resolved older',
        'Active newer',
        'Active older',
        'Active without timestamp',
      ])
    end
  end
end
