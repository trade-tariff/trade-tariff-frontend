RSpec.describe LiveIssueHelper, type: :helper do
  describe '#markdown_field' do
    subject(:markdown_field) { helper.markdown_field(markdown) }

    let(:markdown) { 'This is **bold** text.' }
    let(:expected_html) { "<p>This is <strong>bold</strong> text.</p>\n" }

    it { is_expected.to eq(expected_html) }
  end

  describe '#live_issue_commodity_link' do
    subject(:live_issue_commodity_link) { helper.live_issue_commodity_link(commodity_code) }

    context 'when a commodity code contains non-digit characters' do
      let(:commodity_code) { '3402420090,' }

      it { is_expected.to have_link('3402420090', href: commodity_path('3402420090')) }
    end

    context 'when a commodity code cannot be normalized to ten digits' do
      let(:commodity_code) { 'BAD' }

      it { is_expected.to eq('BAD') }
    end

    context 'when a commodity code contains unexpected characters around ten digits' do
      let(:commodity_code) { '<script>3402420090</script>' }

      it { is_expected.to eq('<script>3402420090</script>') }
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
end
