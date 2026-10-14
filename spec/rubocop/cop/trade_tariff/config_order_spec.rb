require 'rubocop'
require_relative '../../../../.rubocop/cop/trade_tariff/config_order'

RSpec.describe RuboCop::Cop::TradeTariff::ConfigOrder do
  subject(:corrected_source) { correct(source) }

  context 'when methods and flags are out of order' do
    let(:source) do
      <<~RUBY
        module TradeTariffFrontend
          module Config
            def zeta
              'value'
            end

            def alpha?
              true
            end

            flagsmith_value :beta, name: :beta
            flagsmith_flag :gamma?, name: :gamma
            flagsmith_flag :delta?, name: :delta
          end
        end
      RUBY
    end

    it 'sorts the config source' do
      expect(corrected_source).to eq(<<~RUBY)
        module TradeTariffFrontend
          module Config
            def alpha?
              true
            end

            def zeta
              'value'
            end

            flagsmith_flag :delta?, name: :delta
            flagsmith_flag :gamma?, name: :gamma

            flagsmith_value :beta, name: :beta
          end
        end
      RUBY
    end
  end

  def correct(source)
    processed_source = RuboCop::ProcessedSource.new(
      source,
      RUBY_VERSION.to_f,
      'lib/trade_tariff_frontend/config.rb',
    )
    cop = described_class.new(RuboCop::Config.new, autocorrect: true)
    report = RuboCop::Cop::Commissioner.new([cop], [], autocorrect: true).investigate(processed_source)

    report.offenses.first.corrector.rewrite
  end
end
