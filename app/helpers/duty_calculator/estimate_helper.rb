module DutyCalculator
  module EstimateHelper
    # Rules-of-origin scheme codes can be absent or name a CPTPP member country.
    CPTPP_GEOGRAPHICAL_AREA_IDS = (2051..2062).map(&:to_s).freeze
    DCTS_GEOGRAPHICAL_AREA_IDS = %w[1060 1061 1062].freeze
    REDUCED_RATE_ORDER = %w[
      tariff_preference_tariff_preference
      cptpp
      dcts
      suspension_autonomous
      suspension_certain_category_goods
      suspension_airworthiness
      suspension_preferential
      quota_non_preferential
      quota_non_preferential_end_use
      quota_preferential
      quota_preferential_end_use
      quota_customs_union
      suspension_autonomous_end_use
      preference_authorised_use
      non_preferential_authorised_use
    ].freeze

    # Returns standard duty, reduced rates in design order, then other options such as the waiver.
    def duty_estimate_groups(options)
      reduced, remaining = options.partition { |option| reduced_duty_estimate?(option) }
      standard, other = remaining.partition { |option| option.category.to_s == 'third_country_tariff' }
      reduced = reduced.each_with_index.sort_by do |option, index|
        [REDUCED_RATE_ORDER.index(duty_estimate_content_key(option)) || REDUCED_RATE_ORDER.size, index]
      end

      [standard, reduced.map(&:first), other]
    end

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
      return tag.div(option.footnote.to_s.html_safe, class: 'govuk-body') unless I18n.exists?(key)

      explanation = t(
        key,
        rules_of_origin_link:,
        quotas_link: govuk_link_to('understand quotas', '/howto/quotas', new_tab: true),
        equivalent_certificate_link: govuk_link_to('equivalent certificate', 'https://www.gov.uk/guidance/changes-to-customs-tariff-rules-on-imported-aircraft-parts-cip13', new_tab: true),
      )
      safe_join([explanation, option.footnote_suffix])
    end

  private

    def rules_of_origin_link
      govuk_link_to('rules of origin', '/howto/origin', new_tab: true)
    end
  end
end
