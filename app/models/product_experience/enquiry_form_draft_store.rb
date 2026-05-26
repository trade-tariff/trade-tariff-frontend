module ProductExperience
  class EnquiryFormDraftStore
    KEY_PREFIX = 'product_experience:enquiry_form'.freeze
    EXPIRES_IN = 4.hours

    class << self
      attr_writer :client

      def read(draft_id)
        return if draft_id.blank?

        raw_draft = with_client { |redis| redis.get(cache_key(draft_id)) }
        return if raw_draft.blank?

        JSON.parse(raw_draft).to_h.stringify_keys
      end

      def write(draft_id, data)
        return if draft_id.blank?

        key = cache_key(draft_id)
        with_client do |redis|
          redis.set(key, data.to_h.stringify_keys.to_json, ex: EXPIRES_IN.to_i)
        end
      end

      def exists?(draft_id)
        draft_id.present? && with_client { |redis| redis.exists?(cache_key(draft_id)) }
      end

      def delete(draft_id)
        with_client { |redis| redis.del(cache_key(draft_id)) } if draft_id.present?
      end

      def client
        @client ||= build_client
      end

      private

      def build_client
        return Redis.new(url: ENV.fetch('REDIS_URL')) if ENV['REDIS_URL'].present?
        return MockRedis.new if Rails.env.local? || Rails.env.test?

        raise 'REDIS_URL is required for enquiry form draft storage'
      end

      def with_client
        yield client
      end

      def cache_key(draft_id)
        "#{KEY_PREFIX}:#{draft_id}"
      end
    end
  end
end
