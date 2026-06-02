RSpec.describe LiveIssue do
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
