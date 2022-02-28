module ApiResponsesHelper
  # Wrapper around WebMock's stub_request with defaults that apply to all our api requests
  def stub_api_request(endpoint, method = :get, backend: nil)
    backend_url = if backend
                    TradeTariffFrontend::ServiceChooser.service_choices[backend]
                  else
                    TradeTariffFrontend::ServiceChooser.api_host
                  end

    endpoint = "/#{endpoint}" unless endpoint.starts_with?('/')
    url = "#{backend_url}#{endpoint}"

    stub_request(method, url)
  end

  # Generate a JSONAPI response from data suitable for webmock
  def jsonapi_response(type, response_data, status: 200, headers: nil)
    {
      status: status,
      headers: headers || { 'content-type' => 'application/json; charset=utf-8' },
      body: format_jsonapi_response(type, response_data).to_json,
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
    item = { type: type, attributes: attributes }
    item.merge(id: attributes[:id]) if attributes.key?(:id)

    item
  end
end
