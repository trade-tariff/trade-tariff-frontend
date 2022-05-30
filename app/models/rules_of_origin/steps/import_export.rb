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
        I18n.t "title.region_name.#{@store['service']}"
      end

      def trade_country_name
        @trade_country_name ||= GeographicalArea.find(@store['country_code'])
                                                .description
      end
    end
  end
end
