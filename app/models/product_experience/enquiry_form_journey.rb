module ProductExperience
  class EnquiryFormJourney
    CLASSIFICATION_FIELDS = %w[goods_product goods_made_of goods_used_for goods_function goods_processed goods_packaged
                               has_commodity_code commodity_code].freeze
    GENERIC_FIELDS = %w[query].freeze

    class << self
      def normalized_data(field, previous_data, answers)
        data = previous_data.to_h.merge(answers.to_h).stringify_keys
        field == 'category' ? data_for_category(data) : data
      end

      def next_field(current, data = {})
        case current
        when 'category'
          classification?(data) ? 'goods_details' : 'query'
        when 'goods_details'
          'commodity_code'
        when 'commodity_code', 'query'
          'contact_details'
        end
      end

      def previous_field(current, data = {})
        case current
        when 'goods_details', 'query'
          'category'
        when 'commodity_code'
          'goods_details'
        when 'contact_details'
          classification?(data) ? 'commodity_code' : 'query'
        end
      end

      def active_fields(data)
        case route_for_category(data.to_h['category'])
        when :classification
          %w[category goods_details commodity_code contact_details]
        when :generic
          %w[category query contact_details]
        else
          %w[category]
        end
      end

      def continue_journey_after_edit?(field, previous_data, data)
        field == 'category' &&
          route_for_category(previous_data.to_h['category']) != route_for_category(data.to_h['category'])
      end

      private

      def data_for_category(data)
        data = data.except('other_category') unless data['category'] == 'other'

        case route_for_category(data['category'])
        when :classification
          data.except(*GENERIC_FIELDS)
        when :generic
          data.except(*CLASSIFICATION_FIELDS)
        else
          data
        end
      end

      def classification?(data)
        route_for_category(data.to_h['category']) == :classification
      end

      def route_for_category(category)
        return if category.blank?

        category == 'classification' ? :classification : :generic
      end
    end
  end
end
