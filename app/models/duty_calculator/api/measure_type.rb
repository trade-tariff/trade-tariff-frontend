module DutyCalculator
  module Api
    class MeasureType < Api::Base
      TYPE_OPTION_MAPPING = {
        '103' => DutyOptions::ThirdCountryTariff,
        '105' => DutyOptions::ThirdCountryTariff,
        '112' => DutyOptions::Suspension::Autonomous,
        '115' => DutyOptions::Suspension::AutonomousEndUse,
        '117' => DutyOptions::Suspension::CertainCategoryGoods,
        '119' => DutyOptions::Suspension::Airworthiness,
        '141' => DutyOptions::Suspension::Preferential,
        '142' => DutyOptions::TariffPreference,
        '145' => DutyOptions::TariffPreference,
        '106' => DutyOptions::TariffPreference,
        '122' => DutyOptions::Quota::NonPreferential,
        '123' => DutyOptions::Quota::NonPreferentialEndUse,
        '143' => DutyOptions::Quota::Preferential,
        '146' => DutyOptions::Quota::PreferentialEndUse,
        '147' => DutyOptions::Quota::CustomsUnion,
      }.freeze

      TYPE_ADDITIONAL_OPTION_MAPPING = {
        '306' => DutyOptions::AdditionalDuty::Excise,
        '551' => DutyOptions::AdditionalDuty::ProvisionalAntiDumping,
        '552' => DutyOptions::AdditionalDuty::DefinitiveAntiDumping,
        '553' => DutyOptions::AdditionalDuty::ProvisionalCountervailing,
        '554' => DutyOptions::AdditionalDuty::DefinitiveCountervailing,
        '695' => DutyOptions::AdditionalDuty::AdditionalDuties,
        '696' => DutyOptions::AdditionalDuty::AdditionalDutiesSafeguard,
      }.freeze

      EXCISE_MEASURE_TYPE_IDS = [
        '306', # "Excises"
      ].freeze

      # STOPPING MEASURES, DOES NOT YIELD DUTIES
      DECLARATION_MEASURE_TYPE_IDS = [
        '464', # AUTHORISED USE PROVISIONS SUBMISSION
      ].freeze

      DOCUMENT_SUPPORTED_MEASURE_TYPE_IDS = (
        TYPE_OPTION_MAPPING.keys +
        TYPE_ADDITIONAL_OPTION_MAPPING.keys +
        DECLARATION_MEASURE_TYPE_IDS
      ).freeze
      ADDITIONAL_CODE_MEASURE_TYPE_IDS = DOCUMENT_SUPPORTED_MEASURE_TYPE_IDS - EXCISE_MEASURE_TYPE_IDS

      attributes :id,
                 :description,
                 :national,
                 :measure_type_series_id

      enum :measure_type_series_id, {
        applicable_duty: %w[C],
        anti_dumping_and_countervailing_duty: %w[D],
        additional_duty: %w[F],
        countervailing_charge_duty: %w[J],
        unit_price_duty: %w[M],
        excise: %w[Q],
      }

      def option
        TYPE_OPTION_MAPPING[id]
      end

      def additional_duty_option
        TYPE_ADDITIONAL_OPTION_MAPPING[id]
      end

      def self.supported_option_category?(category)
        TYPE_OPTION_MAPPING.values.any? { |option_klass| category == option_klass::CATEGORY }
      end
    end
  end
end
