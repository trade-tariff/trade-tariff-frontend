module ProductExperience
  class EnquiryFormValidator
    QUERY_CHARACTER_LIMIT = 5_000

    class << self
      def errors_for(field, data)
        case field
        when 'category'
          category_errors(data)
        when 'goods_details'
          goods_detail_errors(data)
        when 'commodity_code'
          commodity_code_errors(data)
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

      def error(field, message)
        { field:, message: }
      end
    end
  end
end
