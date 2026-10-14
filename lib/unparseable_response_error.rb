class UnparseableResponseError < StandardError
  def initialize(response)
    @response = response

    super message
  end

  def message
    "Error parsing #{url} with headers: #{headers.inspect}"
  end

private

  def headers
    @response.env[:request_headers]
  end

  def url
    @response.env[:url]
  end
end
