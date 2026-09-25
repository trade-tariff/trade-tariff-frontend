class Search
  class QueryExpansion
    def self.parse(value)
      object = decode(value)
      return if object.nil?

      terms = object.with_indifferent_access[:ai_terms]
      return unless terms.is_a?(Array)
      return unless terms.all? { |term| term.is_a?(String) && term.present? }

      { 'ai_terms' => terms }
    end

    def self.dump(value)
      parsed = parse(value)
      MultiJson.dump(parsed) if parsed
    end

    def self.decode(value)
      case value
      when String
        decoded = JSON.parse(value)
        decoded if decoded.is_a?(Hash)
      when ActionController::Parameters
        value.to_unsafe_h
      when Hash
        value
      end
    rescue JSON::ParserError, TypeError
      nil
    end
    private_class_method :decode
  end
end
