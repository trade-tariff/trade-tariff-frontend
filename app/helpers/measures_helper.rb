module MeasuresHelper
  def filter_duty_expression(measure)
    # NIHIL is an abbreviation (see backend DutyExpressionDescription model),
    # our best guess is that it is used to indicate that a previously applied measure
    # no longer carries any duties.
    return '' if measure.duty_expression.to_s == 'NIHIL'

    measure.measure_type_duty_label || control_line_wrapping_in_duty_expression(measure.duty_expression.to_s)
  end

  def legal_act_regulation_url_link_for(measure)
    legal_act = measure.legal_acts.first

    return '' if legal_act&.regulation_url.blank?

    link = link_to(
      legal_act.regulation_code,
      legal_act.regulation_url,
      target: '_blank',
      rel: 'noopener noreferrer',
      class: 'govuk-link',
      title: legal_act.description,
    )

    sanitize(link, attributes: %w[href target role rel class title])
  end

  def measure_type_description_or_link(measure)
    description = measure.measure_type.description

    if measure.preference_code.present?
      path = measure_type_preference_code_path(measure_type_id: measure.measure_type.id, id: measure.preference_code.code, geographical_area_id: measure.geographical_area.id)
      link_to description, path, title: "#{measure.measure_type.description} - use preference code #{measure.preference_code.code}"
    else
      description
    end
  end

  def check_how_to_export_goods_link(declarable:, country_code:, country_name:, eu_member:)
    if eu_member
      commodity_code_for_check_duties = declarable.commodity_code_for_check_duties_service

      link_to("Check how to export commodity #{declarable.code} to #{country_name} (link opens in new tab)",
              "#{TradeTariffFrontend.check_duties_service_url}/summary?d=#{country_code}&ds=gtp&tab=tree&pc=#{commodity_code_for_check_duties}",
              target: '_blank', rel: 'noopener')
    else
      link_to('Check how to export commodity goods (link opens in new tab)', TradeTariffFrontend.check_duties_service_url, target: '_blank', rel: 'noopener')
    end
  end

  # This rewrites the duty expression, removing existing span tags and applying
  # them in a manner which allows preventing line breaks at confusing points
  # in the expression
  def control_line_wrapping_in_duty_expression(expression)
    # meursing measures are wrapped with strong tags
    wrapping_tag = expression.start_with?('<strong>') ? :strong : :span
    sanitized = sanitize(expression, tags: %w[abbr], attributes: %w[title])
    components = []

    1.upto(20) do
      break unless sanitized.length.positive?

      matched = sanitized.match(%r{ (\+|-|MIN|MAX) })
      if matched
        components << tag.span(sanitized.slice(0, matched.begin(0)).html_safe)
        components << matched[1]
        sanitized = sanitized.slice(matched.end(0), sanitized.length)
      else
        components << tag.span(sanitized.html_safe)
        sanitized = ''
      end
    end

    content_tag(wrapping_tag, class: 'duty-expression') do
      safe_join components.flatten.compact, ' '
    end
  end

  def format_measure_condition_requirement(condition)
    if condition.measure_condition_class.threshold?
      threshold_fallback = condition.requirement.presence || 'Condition not fulfilled'

      t("threshold_requirement_text.#{condition.threshold_unit_type}.#{condition.requirement_operator}_html", requirement_duty_expression: condition.requirement, default: threshold_fallback).html_safe
    else
      (condition.certificate_description.presence ||
        condition.requirement.presence ||
        'No document provided')
        .to_s
        .html_safe
    end
  end

  def format_measure_condition_document_code(condition)
    if condition.measure_condition_class.threshold?
      'Threshold condition'
    else
      condition.document_code
    end
  end

  def format_combined_conditions_requirement(conditions)
    if conditions.length == 2
      if conditions.map(&:measure_condition_class).all?(&:document?)
        'Provide both documents'
      else
        'Meet both conditions'
      end
    elsif conditions.many?
      if conditions.map(&:measure_condition_class).all?(&:document?)
        'Provide all documents'
      else
        'Meet all conditions'
      end
    end
  end

  def vat_messages(measure_collection)
    messages = []
    return messages if measure_collection.blank?

    count = measure_collection.vat.count
    vat_info_message = I18n.t('measure_collection.message_overrides.vat.info_message_html')

    case count
    when 1
      messages.push I18n.t(
        "measure_collection.message_overrides.vat.message_#{count}_html",
        vat: filter_duty_expression(measure_collection.vat.first),
      )
    when 2
      messages.push I18n.t(
        "measure_collection.message_overrides.vat.message_#{count}_html",
        vat: filter_duty_expression(measure_collection.vat.first),
        vat_2: filter_duty_expression(measure_collection.vat.last),
      ).html_safe
      messages.push vat_info_message
    when 3
      messages.push I18n.t(
        "measure_collection.message_overrides.vat.message_#{count}_html",
        vat: filter_duty_expression(measure_collection.vat[0]),
        vat_2: filter_duty_expression(measure_collection.vat[1]),
        vat_3: filter_duty_expression(measure_collection.vat[2]),
      ).html_safe
      messages.push vat_info_message
    else
      messages.push I18n.t(
        'measure_collection.message_overrides.vat.message_1_html',
        vat: filter_duty_expression(measure_collection.measure_with_highest_vat_rate),
      )
    end

    messages.map(&:html_safe)
  end

  def excise_message(measure_collection, commodity_code)
    if measure_collection.excise.any?
      I18n.t('measure_collection.message_overrides.excise.apply_message_html', commodity_code:)
    else
      I18n.t('measure_collection.message_overrides.excise.not_apply_message_html')
    end.html_safe
  end
end
