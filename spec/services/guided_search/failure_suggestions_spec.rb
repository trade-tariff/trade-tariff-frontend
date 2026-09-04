RSpec.describe GuidedSearch::FailureSuggestions do
  subject(:suggestions) { described_class.new(config:, logger:) }

  let(:logger) { instance_double(ActiveSupport::Logger, warn: nil) }
  let(:config) do
    {
      'query_expansion_failed' => {
        'enabled' => true,
        'level' => 'warn',
        'translation_key' => 'search.failure_suggestions.query_expansion_failed',
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

    it 'rejects an entry without a translation key' do
      config['query_expansion_failed'].delete('translation_key')

      expect { suggestions }.to raise_error(
        GuidedSearch::FailureSuggestions::ConfigurationError,
        /query_expansion_failed.*translation_key/,
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

  describe '#messages_for' do
    it 'returns the translated suggestion for an enabled failure' do
      allow(I18n).to receive(:t)
        .with('search.failure_suggestions.query_expansion_failed')
        .and_return('These results are based on the words you entered.')

      expect(suggestions.messages_for(%w[query_expansion_failed]))
        .to eq(['These results are based on the words you entered.'])
    end

    it 'does not return a suggestion when the failure is disabled' do
      config['query_expansion_failed']['enabled'] = false

      expect(suggestions.messages_for(%w[query_expansion_failed])).to eq([])
    end

    it 'returns shared translated copy only once' do
      config['embedding_generation_failed'] = {
        'enabled' => true,
        'level' => 'warn',
        'translation_key' => 'search.failure_suggestions.meaning_matching_failed',
      }
      config['vector_retrieval_failed'] = config['embedding_generation_failed'].dup
      allow(I18n).to receive(:t)
        .with('search.failure_suggestions.meaning_matching_failed')
        .and_return('These results use keyword matching.')

      expect(suggestions.messages_for(%w[embedding_generation_failed vector_retrieval_failed]))
        .to eq(['These results use keyword matching.'])
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

    it 'enables all five codes and returns four unique translated suggestions', :aggregate_failures do
      expect(suggestions.known_codes(all_codes)).to eq(all_codes)
      expect(suggestions.messages_for(all_codes)).to eq([
        'These results are based on the words you entered. Try searching again if they are not useful.',
        'These results use keyword matching. Try searching again if they are not useful.',
        'These are the best available matches. Try searching again if you want to answer questions and refine the results.',
        'These results are based on the meaning of your description. Try searching again if they are not useful.',
      ])
    end
  end
end
