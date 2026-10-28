module DutyCalculator
  module EstimateHelper
    # Rules-of-origin scheme codes can be absent or name a CPTPP member country.
    CPTPP_GEOGRAPHICAL_AREA_IDS = (2051..2062).map(&:to_s).freeze
    DCTS_GEOGRAPHICAL_AREA_IDS = %w[1060 1061 1062].freeze

    def duty_estimate_content_key(option)
      return 'non_preferential_authorised_use' if option.measure_type_id == '105'
      return 'preference_authorised_use' if option.measure_type_id == '145'

      if option.category.to_s == 'tariff_preference'
        return 'cptpp' if CPTPP_GEOGRAPHICAL_AREA_IDS.include?(option.geographical_area_id)
        return 'dcts' if DCTS_GEOGRAPHICAL_AREA_IDS.include?(option.geographical_area_id)
      end

      "#{option.category}_#{option.type}"
    end

    def duty_estimate_name(option)
      t(
        "duty_estimates.#{duty_estimate_content_key(option)}.name",
        default: [
          :"duty_calculations.options.estimate.#{option.category}.#{option.type}",
          :"duty_calculations.options.option_type.#{option.category}.#{option.type}",
          option.type.to_s.humanize,
        ],
        geographical_area_description: option.geographical_area_description,
        order_number: option.order_number,
      )
    end

    def reduced_duty_estimate?(option)
      option.measure_type_id == '105' || option.category.to_s.in?(%w[tariff_preference suspension quota])
    end

    def duty_estimate_introduction(option)
      t("duty_estimates.#{duty_estimate_content_key(option)}.introduction_html", default: '', rules_of_origin_link:)
    end

    def duty_estimate_explanation(option)
      key = "duty_estimates.#{duty_estimate_content_key(option)}.explanation_html"
      return option.footnote.html_safe unless I18n.exists?(key)

      explanation = t(
        key,
        rules_of_origin_link:,
        quotas_link: govuk_link_to('understand quotas', '/howto/quotas', new_tab: true),
      )
      safe_join([explanation, option.footnote_suffix])
    end

  private

    def rules_of_origin_link
      govuk_link_to('rules of origin', '/howto/origin', new_tab: true)
    end
  end
end
