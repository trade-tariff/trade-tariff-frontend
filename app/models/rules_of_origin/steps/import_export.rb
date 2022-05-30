module RulesOfOrigin
  module Steps
    class ImportExport < Base
      OPTIONS = %w[import export].freeze

      attribute :import_or_export

      validates :import_or_export, presence: true, inclusion: { in: :options }

      def options
        OPTIONS
      end

      def service_country_name
        'the UK'
      end

      def trade_country_name
        'Japan'
      end
    end
  end
end
