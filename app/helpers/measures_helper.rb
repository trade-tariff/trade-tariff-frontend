module MeasuresHelper
  def filter_duty_expression(measure)
    return '' if measure.duty_expression.to_s == 'NIHIL'

    control_line_wrapping_in_duty_expression(measure.duty_expression.to_s)
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
    case condition.measure_condition_class
    when 'threshold'
      'FIXME: need unit type'
    else
      (condition.certificate_description.presence || condition.requirement)
        .to_s
        .html_safe
    end
  end

  def format_measure_condition_document_code(condition)
    case condition.measure_condition_class
    when 'threshold'
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
end
