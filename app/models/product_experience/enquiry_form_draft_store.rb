module ProductExperience
  class EnquiryFormDraftStore
    KEY_PREFIX = 'product_experience:enquiry_form'.freeze
    EXPIRES_IN = 4.hours

    class << self
      attr_writer :cache_store

      def read(draft_id)
        return if draft_id.blank?

        cache_store.read(cache_key(draft_id))&.to_h&.stringify_keys
      end

      def write(draft_id, data)
        return if draft_id.blank?

        cache_store.write(cache_key(draft_id), data.to_h.stringify_keys, expires_in: EXPIRES_IN)
      end

      def exists?(draft_id)
        draft_id.present? && cache_store.exist?(cache_key(draft_id))
      end

      def delete(draft_id)
        cache_store.delete(cache_key(draft_id)) if draft_id.present?
      end

      def cache_store
        @cache_store ||= build_cache_store
      end

      private

      def build_cache_store
        return ActiveSupport::Cache::MemoryStore.new if Rails.env.local? || Rails.env.test?
        return Rails.cache unless Rails.cache.is_a?(ActiveSupport::Cache::NullStore)

        raise 'A real cache store is required for enquiry form draft storage'
      end

      def cache_key(draft_id)
        "#{KEY_PREFIX}:#{draft_id}"
      end
    end
  end
end
