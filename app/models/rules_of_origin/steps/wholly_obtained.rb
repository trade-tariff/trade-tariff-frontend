module RulesOfOrigin
  module Steps
    class WhollyObtained < Base
      OPTIONS = %w[yes no].freeze

      self.section = 'originating'

      attribute :wholly_obtained

      validates_each :wholly_obtained do |record, attr, value|
        unless value.in?(record.options)
          record.errors.add \
            attr,
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
    end
  end
end
