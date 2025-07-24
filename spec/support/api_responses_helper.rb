module ApiResponsesHelper
  # Wrapper around WebMock's stub_request with defaults that apply to all our api requests
  def stub_api_request(endpoint, method = :get, backend: nil)
    backend_url = if backend
                    TradeTariffFrontend::ServiceChooser.service_choices[backend]
                  else
                    TradeTariffFrontend::ServiceChooser.api_host
                  end

    url = if endpoint.starts_with?('http')
            endpoint
          elsif endpoint.starts_with?('/')
            "#{backend_url}#{endpoint}"
          else
            "#{backend_url}/#{endpoint}"
          end

    stub_request(method, url)
  end

  # Generate a JSONAPI response from data suitable for webmock
  def jsonapi_response(type, response_data, status: 200, headers: nil)
    {
      status:,
      headers: headers || { 'content-type' => 'application/json; charset=utf-8' },
      body: format_jsonapi_response(type, response_data).to_json,
    }
  end

  def jsonapi_not_found_response
    jsonapi_error_response(404)
  end

  def jsonapi_error_response(status = 500, response_data = nil, headers: nil)
    {
      status:,
      headers: headers || { 'content-type' => 'application/json; charset=utf-8' },
      body: response_data,
    }
  end

  def format_jsonapi_response(type, response)
    case response
    when Hash
      {
        data: format_jsonapi_item(type, response),
      }
    when Array
      {
        data: response.map { |r| format_jsonapi_item(type, r) },
      }
    else
      response
    end
  end

  def format_jsonapi_item(type, attributes)
    item = { type:, attributes: }
    item.merge(id: attributes[:id]) if attributes.key?(:id)

    item
  end
end
