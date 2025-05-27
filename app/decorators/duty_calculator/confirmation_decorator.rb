class ConfirmationDecorator < SimpleDelegator
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TagHelper
  include CommodityHelper
  include UkimsHelper

  ORDERED_STEPS = %w[
    additional_code
    document_code
    import_date
    import_destination
    country_of_origin
    trader_scheme
    final_use
    annual_turnover
    planned_processing
    certificate_of_origin
    meursing_additional_code
    customs_value
    measure_amount
    excise
    vat
  ].freeze

  def path_for(key:)
    send("#{key}_path")
  end

  def user_answers
    ORDERED_STEPS.each_with_object([]) do |(k, _v), acc|
      next if session_answers[k].blank? || (formatted_value = format_value_for(k)).nil?

      acc << {
        key: k,
        label: I18n.t("confirmation_page.#{k}"),
        value: formatted_value,
      }
    end
  end

  private

  def import_date_path
    super(referred_service: user_session.referred_service, commodity_code: user_session.commodity_code)
  end

  def additional_code_path
    additional_codes_path(applicable_measure_type_ids.first)
  end

  def document_code_path
    document_codes_path(document_codes_applicable_measure_type_ids.first)
  end

  def excise_path
    super(applicable_excise_measure_type_ids.first)
  end

  def meursing_additional_code_path
    meursing_additional_codes_path
  end

  def format_value_for(key)
    value = session_answers[key]

    if respond_to?("format_#{key}", true)
      send("format_#{key}", value, key)
    else
      value.humanize
    end
  end

  def session_answers
    @session_answers ||= user_session.session['answers']
  end

  def format_measure_amount(value, _key)
    return if applicable_measure_units.blank?

    formatted_values = value.map do |measure_unit_key, answer|
      applicable_unit = applicable_measure_units[measure_unit_key.upcase]
      unit = if applicable_unit['coerced_measurement_unit_code'].present?
               applicable_unit['unit']
             else
               applicable_unit['expansion'] || applicable_unit['abbreviation'] || applicable_unit['unit']
             end

      content = safe_join(
        [
          tag.span(tag.b(unit), title: applicable_unit['unit_question']),
          tag.br,
          answer,
        ],
        '',
      )
      tag.div(content, id: "measure-#{measure_unit_key}")
    end

    formatted_values.join('').html_safe
  end

  def format_customs_value(_value, _key)
    number_to_currency(user_session.total_amount)
  end

  def format_import_date(value, _key)
    I18n.l(Date.parse(value))
  end

  def format_country_name(value, key)
    return Steps::ImportDestination::OPTIONS.find { |c| c.id == value }.name if key == 'import_destination'

    value = user_session.other_country_of_origin if value == 'OTHER'

    Api::GeographicalArea.build(user_session.import_destination.downcase.to_sym, value.upcase).description
  end

  alias_method :format_import_destination, :format_country_name
  alias_method :format_country_of_origin, :format_country_name

  def format_annual_turnover(value, _key)
    return "Less than #{ukims_annual_turnover}" if value == 'yes'

    "#{ukims_annual_turnover} or more"
  end

  def format_vat(value, _key)
    applicable_vat_options[value]
  end

  def format_additional_code(value, _key)
    return nil unless value.values.any? { |v| v.values.compact.present? }

    user_session.additional_codes
  end

  def format_excise(value, _key)
    return nil unless value.values.any?

    user_session.excise_additional_code.values.join(', ')
  end

  def format_document_code(_value, _key)
    return nil if user_session.document_code_uk.empty? && user_session.document_code_xi.empty?
    return document_codes.uniq.sort.join(', ') if document_codes.present?

    'n/a'
  end

  def document_codes
    uk_document_codes = fetch_document_codes_for('uk')
    xi_document_codes = fetch_document_codes_for('xi')

    uk_document_codes.concat(xi_document_codes)
  end

  def fetch_document_codes_for(source)
    user_session.public_send("document_code_#{source}").values.flatten.reject { |code| code == 'None' }
  end

  def user_session
    UserSession.get
  end
end
