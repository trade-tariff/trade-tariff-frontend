RSpec.describe Search::QueryExpansion do
  describe '.parse' do
    it 'keeps nonblank expansion terms' do
      expect(described_class.parse('ai_terms' => [' live horse ', 'mare'])).to eq(
        'ai_terms' => [' live horse ', 'mare'],
      )
    end

    it 'keeps a known-empty term list' do
      expect(described_class.parse('{"ai_terms":[]}')).to eq('ai_terms' => [])
    end

    it 'accepts nested parameters' do
      value = ActionController::Parameters.new(ai_terms: ['live horse'])

      expect(described_class.parse(value)).to eq('ai_terms' => ['live horse'])
    end

    it 'drops extra keys' do
      expect(described_class.parse('ai_terms' => %w[mare], 'other' => 'value')).to eq('ai_terms' => %w[mare])
    end

    [
      nil,
      '',
      'null',
      '[]',
      '{',
      { 'ai_terms' => nil },
      { 'ai_terms' => 'mare' },
      { 'ai_terms' => ['mare', ''] },
      { 'ai_terms' => ['mare', ' '] },
      { 'ai_terms' => ['mare', 1] },
      { 'other' => [] },
    ].each do |value|
      it "treats #{value.inspect} as unknown" do
        expect(described_class.parse(value)).to be_nil
      end
    end
  end

  describe '.dump' do
    it 'returns JSON for a known-empty term list' do
      expect(described_class.dump('ai_terms' => [])).to eq('{"ai_terms":[]}')
    end

    it 'returns nil for unknown expansion data' do
      expect(described_class.dump('not-json')).to be_nil
    end
  end
end
