module ProductExperience
  class EnquiryFormValidator
    QUERY_CHARACTER_LIMIT = 5_000
    QUOTA_REFERENCE_REQUIREMENTS = {
      'commodity_code' => ['quota_commodity_code', 'Please enter the commodity code.'],
      'quota_order_number' => ['quota_order_number', 'Please enter the quota order number.'],
      'movement_reference_number' => ['movement_reference_number', 'Please enter the Movement Reference Number (MRN).'],
    }.freeze

    class << self
      def errors_for(field, data)
        case field
        when 'category'
          category_errors(data)
        when 'enquiry_type'
          enquiry_type_errors(data)
        when 'goods_details'
          goods_detail_errors(data)
        when 'commodity_code'
          commodity_code_errors(data)
        when 'duty_details'
          detail_query_errors(data)
        when 'quota_details'
          quota_detail_errors(data)
        when 'postal_or_baggage_details'
          postal_or_baggage_detail_errors(data)
        when 'query'
          query_errors(data)
        when 'contact_details'
          contact_detail_errors(data)
        else
          []
        end
      end

      private

      def category_errors(data)
        errors = []
        errors << error('category', 'Please select what you need help with.') if data['category'].blank?
        errors << error('other_category', 'Please add a short label.') if data['category'] == 'other' && data['other_category'].blank?
        errors
      end

      def enquiry_type_errors(data)
        errors = []
        errors << error('enquiry_type', 'Please select what your enquiry relates to.') unless valid_radio_choice?('enquiry_type', data['enquiry_type'])
        errors
      end

      def goods_detail_errors(data)
        errors = []
        errors << error('goods_product', 'Please describe the product.') if data['goods_product'].blank?
        errors << error('goods_made_of', 'Please say what the product is made of.') if data['goods_made_of'].blank?
        errors
      end

      def commodity_code_errors(data)
        errors = []
        if data['has_commodity_code'].blank?
          errors << error('has_commodity_code', 'Please select whether you have a possible commodity code.')
        end
        if data['has_commodity_code'] == 'yes' && data['commodity_code'].blank?
          errors << error('commodity_code', 'Please enter the possible commodity code.')
        end
        errors
      end

      def detail_query_errors(data)
        errors = []
        errors << error('query', 'Please explain how we can help.') if data['query'].blank?
        errors << error('query', 'You can enter up to 5,000 characters.') if text_too_long?(data['query'], QUERY_CHARACTER_LIMIT)
        errors
      end

      def quota_detail_errors(data)
        errors = []
        unless valid_radio_choice?('quota_reference_type', data['quota_reference_type'])
          errors << error('quota_reference_type', 'Please select whether you have a commodity code or quota order number.')
        end
        field, message = QUOTA_REFERENCE_REQUIREMENTS[data['quota_reference_type']]
        errors << error(field, message) if field.present? && data[field].blank?

        errors + detail_query_errors(data)
      end

      def postal_or_baggage_detail_errors(data)
        errors = []
        errors << error('postal_or_baggage', 'Please select what you are asking about.') unless valid_radio_choice?('postal_or_baggage', data['postal_or_baggage'])
        errors << error('item', 'Please enter the item.') if data['item'].blank?
        errors << error('purchase_price', 'Please enter the purchase price.') if data['purchase_price'].blank?
        errors + detail_query_errors(data)
      end

      def query_errors(data)
        errors = []
        errors << error('query', 'Please explain how we can help.') if data['query'].blank?
        errors << error('query', 'You can enter up to 5,000 characters.') if text_too_long?(data['query'], QUERY_CHARACTER_LIMIT)
        errors
      end

      def contact_detail_errors(data)
        errors = []
        errors << error('email_address', 'Please enter your email address.') if data['email_address'].blank?
        if data['email_address'].present? && !data['email_address'].match?(URI::MailTo::EMAIL_REGEXP)
          errors << error('email_address', 'Please enter a valid email address.')
        end
        errors
      end

      def text_too_long?(value, max)
        GovukFrontendHelper.utf16_code_units_length(value.to_s) > max
      end

      def valid_radio_choice?(field, value)
        EnquiryFormHelper::RADIO_OPTIONS.fetch(field).any? { |option| option[:value] == value }
      end

      def error(field, message)
        { field:, message: }
      end
    end
  end
end
