module ProductExperience
  class EnquiryFormDraftStore
    KEY_PREFIX = 'product_experience:enquiry_form'.freeze
    EXPIRES_IN = 4.hours

    class << self
      def read(draft_id)
        return {} if draft_id.blank?

        Rails.cache.read(cache_key(draft_id)).to_h.stringify_keys
      end

      def write(draft_id, data)
        Rails.cache.write(cache_key(draft_id), data.to_h.stringify_keys, expires_in: EXPIRES_IN)
      end

      def delete(draft_id)
        Rails.cache.delete(cache_key(draft_id)) if draft_id.present?
      end

      private

      def cache_key(draft_id)
        "#{KEY_PREFIX}:#{draft_id}"
      end
    end
  end
end
