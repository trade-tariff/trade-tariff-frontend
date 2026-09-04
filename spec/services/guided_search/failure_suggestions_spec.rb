RSpec.describe GuidedSearch::FailureSuggestions do
  subject(:suggestions) { described_class.new(config:, logger:) }

  let(:logger) { instance_double(ActiveSupport::Logger, warn: nil) }
  let(:config) do
    {
      'query_expansion_failed' => {
        'enabled' => true,
        'level' => 'warn',
      },
    }
  end

  describe '#initialize' do
    it 'rejects an invalid failure code' do
      config['Not a valid code'] = config.delete('query_expansion_failed')

      expect { suggestions }.to raise_error(
        GuidedSearch::FailureSuggestions::ConfigurationError,
        /Not a valid code.*code/,
      )
    end

    it 'rejects an unsupported display level' do
      config['query_expansion_failed']['level'] = 'error'

      expect { suggestions }.to raise_error(
        GuidedSearch::FailureSuggestions::ConfigurationError,
        /query_expansion_failed.*level/,
      )
    end

    it 'rejects an entry without a boolean enabled value' do
      config['query_expansion_failed']['enabled'] = 'yes'

      expect { suggestions }.to raise_error(
        GuidedSearch::FailureSuggestions::ConfigurationError,
        /query_expansion_failed.*enabled/,
      )
    end
  end

  describe '#enabled_codes_for' do
    it 'returns an enabled failure code' do
      expect(suggestions.enabled_codes_for(%w[query_expansion_failed]))
        .to eq(%w[query_expansion_failed])
    end

    it 'does not return a suggestion when the failure is disabled' do
      config['query_expansion_failed']['enabled'] = false

      expect(suggestions.enabled_codes_for(%w[query_expansion_failed])).to eq([])
    end
  end

  describe '#known_codes' do
    it 'ignores and logs an unknown failure code', :aggregate_failures do
      expect(suggestions.known_codes(%w[query_expansion_failed future_failure]))
        .to eq(%w[query_expansion_failed])
      expect(logger).to have_received(:warn).with(
        { event: 'guided_search.unknown_failure_code', failure_code: 'future_failure' }.to_json,
      )
    end
  end

  context 'with the application configuration' do
    subject(:suggestions) { described_class.new }

    let(:all_codes) do
      %w[
        query_expansion_failed
        embedding_generation_failed
        vector_retrieval_failed
        interactive_search_failed
        opensearch_failed
      ]
    end

    it 'enables all five codes', :aggregate_failures do
      expect(suggestions.known_codes(all_codes)).to eq(all_codes)
      expect(suggestions.enabled_codes_for(all_codes)).to eq(all_codes)
    end
  end
end
