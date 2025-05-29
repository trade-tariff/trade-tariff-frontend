module DutyCalculator
  module DutyOptions
    class TariffPreference < DutyOptions::Base
      PRIORITY = 2
      CATEGORY = :tariff_preference

      def call
        result = super
        result.geographical_area_description = measure.geographical_area.description
        result
      end
    end
  end
end
