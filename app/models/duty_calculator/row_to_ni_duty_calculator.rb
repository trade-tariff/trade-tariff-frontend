class RowToNiDutyCalculator
  include CommodityHelper

  def initialize(uk_options, xi_options)
    @uk_options = uk_options
    @xi_options = xi_options
  end

  # 1. Encapsulate OptionResult with a footnote
  def options
    options = uk_options.each_with_object(default_options) do |uk_option, acc|
      category = uk_option.category

      next unless Api::MeasureType.supported_option_category?(category)

      option = if category == DutyOptions::ThirdCountryTariff::CATEGORY
                 DutyOptions::Chooser.new(
                   uk_option,
                   xi_options.third_country_tariff_option,
                   user_session.total_amount,
                 ).call
               else
                 cheapest_xi_option = xi_options.public_send("cheapest_#{category}_option")
                 xi_option = cheapest_xi_option || xi_options.third_country_tariff_option

                 option = DutyOptions::Chooser.new(
                   uk_option,
                   xi_option,
                   user_session.total_amount,
                 ).call

                 uk_only = cheapest_xi_option.nil?

                 footnote_suffix = if uk_only
                                     I18n.t("row_to_ni_measure_type_footnotes_suffixes.#{category}.uk_only.#{option.source}_html",
                                            uk_only_text: uk_only_text_for(category, option, uk_option))
                                   end

                 option
               end

      next if option.blank?

      footnote_suffix ||= I18n.t("row_to_ni_measure_type_footnotes_suffixes.#{option.category}.#{option.source}_html")

      option.footnote_suffix = footnote_suffix.html_safe

      acc << option
    end

    options = options.uniq(&:measure_sid)
    options = handle_duplicate_mfn_option(options)
    options.sort_by(&:priority)
  end

  private

  attr_reader :uk_options, :xi_options

  def default_options
    options = []
    options = default_options_for(:tariff_preference) if use_eu_options?(:tariff_preference)
    options = default_options_for(:suspension) if use_eu_options?(:suspension)
    options = default_options_for(:quota) if use_eu_options?(:quota)

    OptionCollection.new(options)
  end

  def default_options_for(category)
    footnote_suffix = I18n.t("row_to_ni_measure_type_footnotes_suffixes.#{category}.xi_only.xi_html")

    xi_options.public_send("#{category}_options").each do |option|
      option.footnote_suffix = footnote_suffix.html_safe
    end
  end

  def handle_duplicate_mfn_option(options)
    return options unless options.third_country_tariff_options.size > 1

    uk_option = options.third_country_tariff_options.find { |option| option.source == 'uk' }
    xi_option = options.third_country_tariff_options.find { |option| option.source == 'xi' }

    option_to_keep = DutyOptions::Chooser.new(uk_option, xi_option, user_session.total_amount).call

    option_to_reject = if option_to_keep == uk_option
                         xi_option
                       else
                         uk_option
                       end

    options.reject { |option| option == option_to_reject }
  end

  def use_eu_options?(category)
    xi_options.public_send("#{category}_options").present? && uk_options.public_send("#{category}_options").blank?
  end

  def uk_only_text_for(category, option, uk_option)
    return option.order_number if category == DutyOptions::Quota::Base::CATEGORY
    return I18n.t("duty_calculations.options.option_type.#{uk_option.type}") if category == DutyOptions::Suspension::Base::CATEGORY

    ''
  end

  def user_session
    UserSession.get
  end
end
