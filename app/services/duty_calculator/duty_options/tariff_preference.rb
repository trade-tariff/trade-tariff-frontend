module DutyCalculator
  module DutyOptions
    class TariffPreference < DutyOptions::Base
      PRIORITY = 2
      CATEGORY = :tariff_preference

      def call
        result = super
        result.geographical_area_description = measure.geographical_area.description
        result.geographical_area_id = measure.geographical_area.id
        result
      end
    end
  end
end
