module DutyCalculator
  class AdditionalDutyApplicableMeasuresMerger
    include CommodityHelper

    def call
      send("#{user_session.commodity_source}_applicable_measures")
    end

  private

    def xi_applicable_measures
      xi_measures_no_excise.concat(uk_filtered_commodity.applicable_excise_measures)
    end

    def uk_applicable_measures
      filtered_commodity.applicable_measures.select(&:applicable?)
    end

    def xi_measures_no_excise
      filtered_commodity.applicable_measures.select(&:applicable?).reject(&:excise)
    end

    def user_session
      UserSession.get
    end
  end
end
