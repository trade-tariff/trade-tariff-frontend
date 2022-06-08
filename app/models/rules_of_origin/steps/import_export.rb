module RulesOfOrigin
  module Steps
    class ImportExport < Base
      OPTIONS = %w[import export].freeze

      attribute :import_or_export

      validates_each :import_or_export do |record, attr, value|
        unless value.in?(record.options)
          record.errors.add \
            :import_or_export,
            I18n.t(
              "#{i18n_scope}.errors.models.#{model_name.i18n_key}.attributes.#{attr}.inclusion",
              service_country: record.service_country_name,
              trade_country: record.trade_country_name,
            )
        end
      end

      def options
        OPTIONS
      end

      def unilateral_scheme?
        @unilateral_scheme ||= !!chosen_scheme.unilateral
      end
    end
  end
end
