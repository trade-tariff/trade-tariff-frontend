module DutyCalculator
  class ApplicableMeasureUnitMerger
    include CommodityHelper

    UNHANDLED_MEASURE_UNITS = %w[
      FC1X
    ].freeze

    def initialize(dedupe: true)
      @dedupe = dedupe
    end

    def call
      return delta_measure_units if user_session.deltas_applicable?

      send("#{user_session.commodity_source}_measure_units")
    end

  private

    def delta_measure_units
      uk_units = uk_filtered_commodity.applicable_measure_units
      xi_units = xi_filtered_commodity.applicable_measure_units
      applicable_units = uk_units.merge(xi_units)

      clean_and_dedup_measure_units(applicable_units)
    end

    def uk_measure_units
      applicable_units = uk_filtered_commodity.applicable_measure_units

      clean_and_dedup_measure_units(applicable_units)
    end

    def xi_measure_units
      uk_units = uk_filtered_commodity.applicable_excise_measure_units
      xi_units = xi_filtered_commodity.applicable_measure_units
      applicable_units = xi_units.merge(uk_units)

      clean_and_dedup_measure_units(applicable_units)
    end

    def clean_and_dedup_measure_units(applicable_units)
      if @dedupe
        applicable_units = applicable_units.each_with_object({}) do |(code, values), units|
          units[values['coerced_measurement_unit_code'].presence || code] = values
        end
      end

      applicable_units.except(*UNHANDLED_MEASURE_UNITS)
    end

    def user_session
      UserSession.get
    end
  end
end
