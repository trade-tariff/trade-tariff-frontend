module GuidedSearch
  class ImageDescription
    InvalidResponse = Class.new(StandardError)
    MAX_BYTES = 15 * 1024 * 1024
    ID_PATTERN = /\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i

    def self.submit(image)
      # The backend detects the image format from these bytes, not a browser MIME type.
      image.rewind
      bytes = image.read(MAX_BYTES + 1)
      raise InvalidResponse if bytes.blank? || bytes.bytesize > MAX_BYTES

      boundary = "image-description-#{SecureRandom.hex(24)}"
      body = "--#{boundary}\r\nContent-Disposition: form-data; name=\"image\"; filename=\"product-image\"\r\nContent-Type: application/octet-stream\r\n\r\n".b +
        bytes.b + "\r\n--#{boundary}--\r\n".b
      response = Search.api.post(path, body, 'Content-Type' => "multipart/form-data; boundary=#{boundary}", 'Accept' => 'application/json') do |request|
        request.options.timeout = 10
      end
      payload = parse(response)
      raise InvalidResponse unless response.status == 202 && payload['id'].to_s.match?(ID_PATTERN) && payload['status'] == 'queued'

      payload.fetch('id')
    end

    def self.find(id)
      raise InvalidResponse unless id.is_a?(String) && id.match?(ID_PATTERN)

      response = Search.api.get("#{path}/#{id}", {}, 'Cache-Control' => 'no-store', 'Accept' => 'application/json') do |request|
        request.options.timeout = 5
      end
      payload = parse(response)
      raise InvalidResponse unless response.status == 200 && payload['id'] == id && valid_state?(payload)

      payload.slice('status', 'description', 'uncertainties')
    end

    def self.valid_state?(payload)
      case payload['status']
      when 'queued', 'running', 'failed'
        true
      when 'completed'
        payload['description'].is_a?(String) && payload['description'].present? &&
          payload['description'].length <= 1000 && payload['uncertainties'].is_a?(Array) &&
          payload['uncertainties'].all? { |item| item.is_a?(String) }
      else
        false
      end
    end
    private_class_method :valid_state?

    def self.path
      host = TradeTariffFrontend::ServiceChooser.api_host
      "#{URI.parse(host).path.sub(%r{/api\b}, '/internal')}/image_descriptions"
    end
    private_class_method :path

    def self.parse(response)
      body = response.body
      body = JSON.parse(body) if body.is_a?(String)
      raise InvalidResponse unless body.is_a?(Hash)

      body
    rescue JSON::ParserError
      raise InvalidResponse
    end
    private_class_method :parse
  end
end
