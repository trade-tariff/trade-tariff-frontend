module MeasuresHelper
  DEFAULT_MODAL_CONFIG = {
    content_file: nil,
    overwrite: nil,
  }.freeze

  def modal_partial_options_for(declarable, measure)
    config = config_for(
      declarable.goods_nomenclature_item_id,
      measure.additional_code.code,
      measure.measure_type.id,
    )

    overwrite = config['overwrite']
    content_file = config['content_file']

    if content_file.present?
      if overwrite
        { partial: "measures/measure_condition_replacement_modals/#{content_file}" }
      else
        { partial: 'measures/measure_condition_modal_augment', locals: { modal_content_file: content_file } }
      end
    else
      { partial: 'measures/measure_condition_modal_default', locals: { measure: measure } }
    end
  end

  def config_for(goods_nomenclature_item_id, additional_code, measure_type_id)
    config = TradeTariffFrontend.measure_condition_modal_config.find do |modal_config|
      modal_config['goods_nomenclature_item_id'] == goods_nomenclature_item_id &&
        modal_config['additional_code'] == additional_code &&
        modal_config['measure_type_id'] == measure_type_id
    end

    config || DEFAULT_MODAL_CONFIG
  end

  def filter_duty_expression(measure)
    duty_expression = measure.duty_expression.to_s.html_safe
    duty_expression = '' if duty_expression == 'NIHIL'
    duty_expression
  end

  def legal_act_regulation_url_link_for(measure)
    legal_act = measure.legal_acts.first

    return '' if legal_act&.regulation_url.blank?

    link = link_to(
      legal_act.regulation_code,
      legal_act.regulation_url,
      target: '_blank',
      rel: 'noopener norefferer',
      class: 'govuk-link',
      title: legal_act.description,
    )

    sanitize(link, attributes: %w[href target role rel class title])
  end
end
