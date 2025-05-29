module DutyCalculator
  module DutyOptions
    class ThirdCountryTariff < DutyOptions::Base
      PRIORITY = 1
      CATEGORY = :third_country_tariff

      def call
        result = super
        result.warning_text = I18n.t('duty_calculations.options.mfn.warning_text')
        result
      end
    end
  end
end
