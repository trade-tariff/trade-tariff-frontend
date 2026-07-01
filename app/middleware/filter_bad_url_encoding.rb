class FilterBadUrlEncoding
  def initialize(app)
    @app = app
  end

  def call(env)
    @query_string = env['QUERY_STRING'].to_s
    @path_string = env['PATH_INFO'].to_s
    begin
      return bad_request unless @path_string.ascii_only? && @query_string.ascii_only?

      Rack::Utils.parse_nested_query @query_string
    rescue Rack::Utils::InvalidParameterError
      return bad_request
    end

    @app.call(env)
  end

  def bad_request
    @status = 400
    [
      @status,
      { 'Content-Type' => 'application/json' },
      error_object,
    ]
  end

  def error_object
    [
      {
        errors: [
          {
            status: @status.to_s,
            title: 'There was a problem with your query',
            source: { parameter: 'Invalid query string' },
          },
        ],
      }.to_json,
    ]
  end
end
