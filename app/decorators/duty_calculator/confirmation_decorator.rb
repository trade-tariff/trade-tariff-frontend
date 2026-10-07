module DutyCalculator
  class ConfirmationDecorator < SimpleDelegator
    include ActionView::Helpers::NumberHelper
    include ActionView::Helpers::TagHelper
    include CommodityHelper
    include UkimsHelper
    include VatSummaryHelper

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

    # Steps shown in their own sections on the new Check your answers page.
    UX_SECTION_STEPS = %w[import_date import_destination country_of_origin customs_value vat].freeze

    def path_for(key:)
      send("#{key}_path")
    end

    # Rows for the new Check your answers page: one row for each section of the journey.
    def ux_rows
      rows = [
        section_row('Tell us about this import', import_details_answers, import_details_step_path, 'import details'),
        section_row('What did you pay for the goods and delivery?', valuation_answers, customs_value_path, 'value of the import'),
      ].compact
      rows += other_answers.map do |answer|
        { key: { text: answer[:label] }, value: { text: answer[:value] }, actions: [{ href: path_for(key: answer[:key]), visually_hidden_text: answer[:label] }] }
      end
      vat = vat_row
      rows << vat if vat
      rows
    end

    def import_details_step_path
      import_details_path(commodity_code: user_session.commodity_code)
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

    # As on the existing page, questions without an answer are left out.
    def section_row(title, answers, href, hidden_text)
      answers = answers.reject { |_question, answer| answer.blank? }
      return if answers.empty?

      {
        key: { text: title },
        value: { text: safe_join(answers.map { |question, answer| tag.p(safe_join([tag.strong(question), tag.br, answer]), class: 'govuk-body') }) },
        actions: [{ href:, visually_hidden_text: hidden_text }],
      }
    end

    def import_details_answers
      [
        ['Which part of the UK are you importing into?', import_destination_name(user_session.import_destination)],
        ['What is the country of origin?', origin_long_description],
        ['Date of import', user_session.import_date&.to_formatted_s(:long)],
      ]
    end

    def origin_long_description
      return if user_session.import_destination.blank? || user_session.origin_country_code.blank?

      Api::GeographicalArea.build(user_session.import_destination.downcase.to_sym, user_session.origin_country_code.upcase).long_description
    end

    def valuation_answers
      return [] if user_session.monetary_value.blank?

      [
        ['Value of the goods being imported', format_money(user_session.monetary_value)],
        ['Shipping cost', format_money(user_session.shipping_cost)],
        ['Insurance cost', format_money(user_session.insurance_cost)],
      ]
    end

    # The VAT rate used by the calculator, also when the VAT page was skipped
    # because the commodity has only one rate.
    def vat_row
      vat_code = user_session.vat.presence || (applicable_vat_options.keys.first if applicable_vat_options.size == 1)
      return if vat_code.blank?

      assumed = user_session.vat_assumed && user_session.vat.present?

      {
        key: { text: 'Which VAT rate applies to your import?' },
        value: { text: vat_rate_summary(vat_code, assumed:, fallback: applicable_vat_options[vat_code], bold: true) },
        # A single VAT rate cannot be changed, so it has no Change link (the VAT page is skipped today).
        actions: applicable_vat_options.size > 1 ? [{ href: vat_path, visually_hidden_text: 'VAT rate' }] : [],
      }
    end

    def other_answers
      user_answers.reject { |answer| answer[:key].in?(UX_SECTION_STEPS) }
    end

    def import_date_path
      params_hash = { commodity_code: user_session.commodity_code }
      if user_session.import_date.present?
        params_hash[:day] = user_session.import_date.day
        params_hash[:month] = user_session.import_date.month
        params_hash[:year] = user_session.import_date.year
      end
      super(**params_hash)
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

    # A blank optional cost counts as zero, as in the existing customs value total.
    def format_money(value)
      number_to_currency(value.presence || 0)
    end

    def format_customs_value(_value, _key)
      number_to_currency(user_session.total_amount)
    end

    def format_import_date(value, _key)
      Time.zone.parse(value).to_formatted_s(:gov)
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
end
