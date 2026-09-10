module GuidedSearch
  class QueuedSearch
    InvalidResponse = Class.new(StandardError)
    ID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

    def self.submit(search)
      response = Search.api.post(path, MultiJson.dump(search.internal_search_params), 'Content-Type' => 'application/json') do |request|
        request.options.timeout = 5
      end
      payload = parse(response)
      raise InvalidResponse unless response.status == 202 && payload['id'].to_s.match?(ID_PATTERN)

      payload.fetch('id')
    end

    def self.find(id)
      response = Search.api.get("#{path}/#{id}", {}, 'Cache-Control' => 'no-store') do |request|
        request.options.timeout = 5
      end
      payload = parse(response)
      raise InvalidResponse unless response.status == 200 && payload['id'] == id && %w[queued running completed failed].include?(payload['status'])

      if payload['status'] == 'completed'
        raise InvalidResponse unless payload['response_status'] == 200

        payload['result'] = completed_result(payload['result'])
      end

      payload
    end

    def self.completed_result(body)
      raise InvalidResponse unless body.is_a?(Hash) && body['data'].is_a?(Array) && !body.key?('errors')
      raise InvalidResponse unless body['data'].all? { |resource| valid_resource?(resource) }
      raise InvalidResponse unless valid_meta?(body['meta'])

      Search.internal_result(body)
    rescue TariffJsonapiParser::ParsingError, JSON::ParserError, TypeError, NoMethodError, ArgumentError, KeyError
      raise InvalidResponse
    end
    private_class_method :completed_result

    def self.valid_resource?(resource)
      return false unless resource.is_a?(Hash) && %w[id type].all? { |key| resource[key].is_a?(String) && resource[key].present? }

      attributes = resource['attributes']
      return false unless attributes.is_a?(Hash)
      return false unless %w[goods_nomenclature_item_id goods_nomenclature_class].all? { |key| attributes[key].is_a?(String) && attributes[key].present? }

      # Keep the shared unknown-name fallback without instantiating unrelated constants.
      model_class = attributes['goods_nomenclature_class'].safe_constantize
      model_class.nil? || (model_class.is_a?(Class) && model_class <= GoodsNomenclature)
    end
    private_class_method :valid_resource?

    def self.valid_meta?(meta)
      return true if meta.nil?
      return false unless meta.is_a?(Hash) && optional_types?(meta, 'interactive_search' => Hash, 'description_intercept' => Hash, 'search_failures' => Array)
      return false unless Array(meta['search_failures']).all? { |code| code.is_a?(String) }

      interactive = meta['interactive_search']
      if interactive
        return false unless optional_types?(interactive, 'answers' => Array, 'result_limit' => Integer, 'request_id' => String, 'query' => String, 'expanded_query' => String)
        return false if interactive['request_id'] && !interactive['request_id'].match?(Search::GUIDED_REQUEST_ID_PATTERN)
        return false if interactive['result_limit'] && interactive['result_limit'].negative?
        return false unless Array(interactive['answers']).all? { |answer| valid_answer?(answer) }
      end

      intercept = meta['description_intercept']
      return true unless intercept

      optional_types?(intercept, 'message_header' => String, 'message' => String) &&
        [nil, true, false].include?(intercept['excluded'])
    end
    private_class_method :valid_meta?

    def self.valid_answer?(answer)
      return false unless answer.is_a?(Hash) && answer['question'].is_a?(String) && answer['question'].present?
      return false unless answer['options'].is_a?(Array) && answer['options'].all? { |option| option.is_a?(String) }
      return false unless optional_types?(answer, 'answer' => String)
      return answer['answer'].present? unless answer['answer'].nil?

      answer['options'].any? && answer['options'].all?(&:present?)
    end
    private_class_method :valid_answer?

    def self.optional_types?(attributes, types)
      types.all? { |key, type| attributes[key].nil? || attributes[key].is_a?(type) }
    end
    private_class_method :optional_types?

    def self.path
      host = TradeTariffFrontend::ServiceChooser.api_host
      "#{URI.parse(host).path.sub(%r{/api\b}, '/internal')}/queued_searches"
    end
    private_class_method :path

    def self.parse(response)
      body = response.body.is_a?(Hash) ? response.body : JSON.parse(response.body)
      raise InvalidResponse unless body.is_a?(Hash)

      body
    rescue JSON::ParserError
      raise InvalidResponse
    end
    private_class_method :parse
  end
end
