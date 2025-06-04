module DutyCalculator
  class UserSession
    include UserSessionAttributes

    attr_reader :session

    answer_attributes :import_date,
                      :import_destination,
                      :country_of_origin,
                      :other_country_of_origin,
                      :trader_scheme,
                      :final_use,
                      :certificate_of_origin,
                      :annual_turnover,
                      :planned_processing,
                      :customs_value,
                      :measure_amount,
                      :vat,
                      :meursing_additional_code

    non_answer_attributes :commodity_code,
                          :commodity_source,
                          :referred_service,
                          :trade_defence,
                          :zero_mfn_duty,
                          :redirect_to

    attribute_for_uk_and_xi :additional_code, :document_code

    alias_method :trade_defence?, :trade_defence
    alias_method :zero_mfn_duty?, :zero_mfn_duty

    def initialize(session)
      @session = session
      @session['answers'] ||= {}
      @session['answers'][Steps::AdditionalCode.id] ||= { 'xi' => {}, 'uk' => {} }
      @session['answers'][Steps::DocumentCode.id] ||= { 'xi' => {}, 'uk' => {} }
      @session['answers'][Steps::Excise.id] ||= {}
    end

    class << self
      def build_from_params(session, params)
        import_destination = params[:import_destination]
        country_of_origin = params[:country_of_origin]
        service = (import_destination == 'XI' ? 'xi' : 'uk')
        other_country_of_origin = ''

        # This reflects an idiosyncrasy in the xi_option form for country_of_origin and how we store the value on the session slightly differently. We'd need to refactor the way we access that if we want to remove this and just use country_of_origin as per the gb and non-row ni routes.
        if use_other_country_of_origin?(import_destination, country_of_origin)
          other_country_of_origin = country_of_origin
          country_of_origin = 'OTHER'
        end

        user_session = new(session)
        user_session.commodity_source = service
        user_session.referred_service = service
        user_session.commodity_code = params[:commodity_code]
        user_session.import_date = params[:import_date]
        user_session.import_destination = params[:import_destination]
        user_session.country_of_origin = country_of_origin
        user_session.other_country_of_origin = other_country_of_origin
        user_session.redirect_to = params[:redirect_to]

        Thread.current[:user_session] = user_session
      end

      def build(session)
        Thread.current[:user_session] = new(session)
      end

      def set(value)
        Thread.current[:user_session] = value
      end

      def get
        Thread.current[:user_session]
      end

      private

      def use_other_country_of_origin?(import_destination, country_of_origin)
        import_destination == 'XI' &&
          country_of_origin != 'GB' &&
          !Api::GeographicalArea.eu_member?(country_of_origin)
      end
    end

    def remove_step_ids(ids)
      ids.map { |id| session['answers'].delete(id) } unless ids.empty?
    end

    def import_date
      return if session['answers'][Steps::ImportDate.id].blank?

      Date.parse(session['answers'][Steps::ImportDate.id])
    end

    def customs_value=(values)
      session['answers'][Steps::CustomsValue.id] = {
        'monetary_value' => values['monetary_value'],
        'shipping_cost' => values['shipping_cost'],
        'insurance_cost' => values['insurance_cost'],
      }
    end

    def additional_code_for(measure_type_id, source = 'uk')
      public_send("additional_code_#{source}")[measure_type_id]
    end

    def excise_additional_code_for(measure_type_id)
      excise_additional_code[measure_type_id]
    end

    def document_code_for(measure_type_id, source)
      public_send("document_code_#{source}")[measure_type_id]
    end

    def measure_amount_for(measurement_unit)
      measure_amount[measurement_unit.to_s.downcase]
    end

    def excise_additional_code=(value)
      session['answers'][Steps::Excise.id].merge!(value)
    end

    def excise_additional_code
      session['answers'][Steps::Excise.id]
    end

    def excise_measure_type_ids
      session['answers'][Steps::Excise.id].keys
    end

    def additional_code_measure_type_ids
      return additional_code_uk.merge(additional_code_xi).keys if deltas_applicable?

      session['answers'][Steps::AdditionalCode.id][commodity_source].keys
    end

    def document_code_measure_type_ids
      return document_code_uk.merge(document_code_xi).keys if deltas_applicable?

      session['answers'][Steps::DocumentCode.id][commodity_source].keys
    end

    def measure_amount
      session['answers'][Steps::MeasureAmount.id] || {}
    end

    def monetary_value
      session['answers'][Steps::CustomsValue.id].try(:[], 'monetary_value')
    end

    def shipping_cost
      session['answers'][Steps::CustomsValue.id].try(:[], 'shipping_cost')
    end

    def insurance_cost
      session['answers'][Steps::CustomsValue.id].try(:[], 'insurance_cost')
    end

    def ni_to_gb_route?
      import_destination == 'UK' && country_of_origin == 'XI'
    end

    def gb_to_ni_route?
      import_destination == 'XI' && country_of_origin == 'GB'
    end

    def eu_to_ni_route?
      import_destination == 'XI' && Api::GeographicalArea.eu_member?(country_of_origin)
    end

    def row_to_gb_route?
      import_destination == 'UK' && country_of_origin != 'XI'
    end

    def row_to_ni_route?
      import_destination == 'XI' && country_of_origin == 'OTHER' && other_country_of_origin.present?
    end

    def total_amount
      customs_value.values.map(&:to_f).reduce(:+)
    end

    def unacceptable_processing?
      planned_processing == 'commercial_purposes'
    end
    alias_method :commercial_purposes?, :unacceptable_processing?

    def acceptable_processing?
      !unacceptable_processing?
    end

    def deltas_applicable?
      row_to_ni_route? &&
        no_trade_defence? &&
        no_zero_mfn_duty? &&
        trader_scheme? &&
        final_use_in_ni? &&
        small_turnover_or_non_commercial_purposes?
    end

    def meursing_route?
      gb_to_ni_route? || row_to_ni_route?
    end

    def import_into_gb?
      import_destination == 'UK'
    end

    def no_duty_to_pay?
      no_duty_route? || possible_duty_route? && no_duty_applies?
    end

    def additional_codes
      (additional_code_uk.values + additional_code_xi.values).compact.join(', ')
    end

    def has_answer?(step_id)
      answer = answers[step_id]

      if answer.present? && answer&.key?('xi') || answer&.key?('uk')
        answer['xi'].present? || answer['uk'].present?
      else
        answer.present?
      end
    end

    def answers
      session['answers']
    end

    def origin_country_code
      country_of_origin == 'OTHER' ? other_country_of_origin : country_of_origin
    end

  private

    def trader_scheme?
      trader_scheme == 'yes'
    end

    def final_use_in_ni?
      final_use == 'yes'
    end

    def small_turnover_or_non_commercial_purposes?
      small_turnover? || !commercial_purposes?
    end

    def no_trade_defence?
      !trade_defence?
    end

    def no_zero_mfn_duty?
      !zero_mfn_duty?
    end

    def no_duty_route?
      ni_to_gb_route? || eu_to_ni_route?
    end

    def possible_duty_route?
      gb_to_ni_route? || row_to_gb_route?
    end

    def no_duty_applies?
      zero_mfn_duty_no_trade_defence? || small_turnover? || strict_processing? || certificate_of_origin?
    end

    def strict_processing?
      planned_processing.in?(%w[without_any_processing commercial_processing])
    end

    def small_turnover?
      annual_turnover == 'yes'
    end

    def zero_mfn_duty_no_trade_defence?
      no_trade_defence? && zero_mfn_duty?
    end

    def certificate_of_origin?
      certificate_of_origin == 'yes'
    end
  end
end
