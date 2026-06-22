module ProductExperience
  class EnquiryFormJourney
    IMPORT_DUTIES_AND_QUOTAS = 'import_duties_and_quota'.freeze

    CLASSIFICATION_FIELDS = %w[goods_product goods_made_of goods_used_for goods_function goods_processed goods_packaged
                               has_commodity_code commodity_code].freeze
    GENERIC_FIELDS = %w[query].freeze
    DUTIES_AND_QUOTAS_FIELDS = %w[
      enquiry_type duty_commodity_code customs_value country_of_origin destination query quota_reference_type
      quota_commodity_code quota_order_number movement_reference_number postal_or_baggage postal_commodity_code item
      purchase_price transport_cost
    ].freeze
    DETAIL_FIELD_BY_ENQUIRY_TYPE = {
      'import_duties' => 'duty_details',
      'quotas' => 'quota_details',
      'postal_or_baggage' => 'postal_or_baggage_details',
    }.freeze
    DETAIL_FIELDS_BY_ENQUIRY_TYPE = {
      'import_duties' => %w[duty_commodity_code customs_value country_of_origin destination query],
      'quotas' => %w[
        quota_reference_type quota_commodity_code quota_order_number movement_reference_number country_of_origin
        destination query
      ],
      'postal_or_baggage' => %w[postal_or_baggage postal_commodity_code item purchase_price transport_cost query],
    }.freeze
    QUOTA_REFERENCE_FIELD_BY_TYPE = {
      'commodity_code' => 'quota_commodity_code',
      'quota_order_number' => 'quota_order_number',
      'movement_reference_number' => 'movement_reference_number',
    }.freeze

    class << self
      def normalized_data(field, previous_data, answers)
        data = previous_data.to_h.merge(answers.to_h).stringify_keys

        case field
        when 'category'
          data_for_category(data)
        when 'commodity_code'
          data_for_commodity_code(data)
        when 'enquiry_type'
          data_for_enquiry_type(data)
        when 'quota_details'
          data_for_quota_details(data)
        else
          data
        end
      end

      def next_field(current, data = {})
        case current
        when 'category'
          return 'goods_details' if classification?(data)
          return 'enquiry_type' if duties_and_quotas?(data)

          'query'
        when 'enquiry_type'
          detail_field_for(data.to_h['enquiry_type'])
        when 'goods_details'
          'commodity_code'
        when 'commodity_code', 'duty_details', 'quota_details', 'postal_or_baggage_details', 'query'
          'contact_details'
        end
      end

      def previous_field(current, data = {})
        case current
        when 'goods_details', 'enquiry_type', 'query'
          'category'
        when 'commodity_code'
          'goods_details'
        when 'duty_details', 'quota_details', 'postal_or_baggage_details'
          'enquiry_type'
        when 'contact_details'
          return 'commodity_code' if classification?(data)
          return detail_field_for(data.to_h['enquiry_type']) if duties_and_quotas?(data)

          'query'
        end
      end

      def active_fields(data)
        case route_for_category(data.to_h['category'])
        when :classification
          %w[category goods_details commodity_code contact_details]
        when :duties_and_quotas
          ['category', 'enquiry_type', detail_field_for(data.to_h['enquiry_type']), 'contact_details'].compact
        when :generic
          %w[category query contact_details]
        else
          %w[category]
        end
      end

      def continue_journey_after_edit?(field, previous_data, data)
        category_route_changed = field == 'category' &&
          route_for_category(previous_data.to_h['category']) != route_for_category(data.to_h['category'])
        detail_route_changed = field == 'enquiry_type' &&
          detail_field_for(previous_data.to_h['enquiry_type']) != detail_field_for(data.to_h['enquiry_type'])

        category_route_changed || detail_route_changed
      end

      def detail_field_for(enquiry_type)
        DETAIL_FIELD_BY_ENQUIRY_TYPE[enquiry_type]
      end

      private

      def data_for_category(data)
        data = data.except('other_category') unless data['category'] == 'other'

        case route_for_category(data['category'])
        when :classification
          data.except(*GENERIC_FIELDS, *DUTIES_AND_QUOTAS_FIELDS)
        when :duties_and_quotas
          data.except(*GENERIC_FIELDS, *CLASSIFICATION_FIELDS)
        when :generic
          data.except(*CLASSIFICATION_FIELDS, *DUTIES_AND_QUOTAS_FIELDS)
        else
          data
        end
      end

      def data_for_commodity_code(data)
        return data if data['has_commodity_code'] == 'yes'

        data.except('commodity_code')
      end

      def data_for_enquiry_type(data)
        selected_detail_fields = DETAIL_FIELDS_BY_ENQUIRY_TYPE.fetch(data['enquiry_type'], [])
        stale_detail_fields = DUTIES_AND_QUOTAS_FIELDS - %w[enquiry_type] - selected_detail_fields

        data.except(*stale_detail_fields)
      end

      def data_for_quota_details(data)
        selected_reference_field = QUOTA_REFERENCE_FIELD_BY_TYPE[data['quota_reference_type']]
        stale_reference_fields = QUOTA_REFERENCE_FIELD_BY_TYPE.values - [selected_reference_field]

        data.except(*stale_reference_fields)
      end

      def classification?(data)
        route_for_category(data.to_h['category']) == :classification
      end

      def duties_and_quotas?(data)
        route_for_category(data.to_h['category']) == :duties_and_quotas
      end

      def route_for_category(category)
        return if category.blank?

        return :classification if category == 'classification'
        return :duties_and_quotas if category == IMPORT_DUTIES_AND_QUOTAS

        :generic
      end
    end
  end
end
