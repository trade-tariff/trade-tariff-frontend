module DutyCalculator
  class ApplicableDocumentCodesService
    include CommodityHelper

    def initialize
      @applicable_document_codes = {}
    end

    def call
      if user_session.deltas_applicable?
        delta_measure_condition_documents
      else
        send("#{user_session.commodity_source}_measure_condition_documents")
      end

      @applicable_document_codes
    end

  private

    def delta_measure_condition_documents
      @applicable_document_codes['uk'] = surface_document_codes(uk_filtered_commodity)
      @applicable_document_codes['xi'] = surface_document_codes(xi_filtered_commodity)
    end

    def uk_measure_condition_documents
      @applicable_document_codes['uk'] = surface_document_codes(uk_filtered_commodity)
    end

    def xi_measure_condition_documents
      @applicable_document_codes['xi'] = surface_document_codes(xi_filtered_commodity)
    end

    def surface_document_codes(commodity)
      document_codes = commodity.applicable_measures.each_with_object({}) do |measure, acc|
        next unless measure.expresses_document?
        next if measure.document_codes.blank?

        acc[measure.measure_type.id] ||= Set.new
        acc[measure.measure_type.id] = acc[measure.measure_type.id] | measure.document_codes
      end

      document_codes = document_codes.each_with_object({}) do |(measure_type_id, measure_type_document_codes), acc|
        measure_type_document_codes = measure_type_document_codes.to_a
        last_option = measure_type_document_codes.delete(code: 'None', description: 'None of the above')

        acc[measure_type_id] = measure_type_document_codes.sort_by { |document_code| document_code[:code] }
        acc[measure_type_id] << last_option if last_option
      end

      document_codes.slice(*Api::MeasureType::DOCUMENT_SUPPORTED_MEASURE_TYPE_IDS)
    end

    def user_session
      UserSession.get
    end
  end
end
