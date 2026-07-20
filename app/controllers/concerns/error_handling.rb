module ErrorHandling
  extend ActiveSupport::Concern

  private

  def handle_too_many_requests_error
    redirect_to '/429'
  end

  # Methods below are used to handle errors and
  # exceptions as we principally don't need these ending up in our error logging
  def raise_not_found(exception)
    Rails.logger.info(exception.message)
    redirect_to '/404', status: :not_found
  end

  alias_method :handle_invalid_uri_error, :raise_not_found
  alias_method :handle_unknown_format, :raise_not_found

  def bad_request(exception)
    Rails.logger.info(exception.message)
    redirect_to '/400', status: :bad_request
  end

  def handle_invalid_search_date(exception)
    return bad_request(exception) unless request.get? && request.format.html?

    Rails.logger.info(exception.message)
    redirect_to invalid_date_redirect_options
  end

  def invalid_date_redirect_options
    request.path_parameters.except(:day, :month, :year, 'day', 'month', 'year').merge(
      request.query_parameters.except('day', 'month', 'year'),
      day: nil,
      month: nil,
      year: nil,
      invalid_date: true,
      only_path: true,
    )
  end

  def raise_internal_server_error(exception)
    @handled_exception_log_context = handled_exception_log_context(exception)
    NewRelic::Agent.notice_error(exception, custom_params: @handled_exception_log_context)
    Rails.logger.error(@handled_exception_log_context.to_json)
    redirect_to '/500', status: :internal_server_error
  end

  def handled_exception_log_context(exception)
    {
      exception_class: exception.class.name,
      exception_message: exception.message,
      search_request_id: @search&.request_id,
      experiment_label: Current.experiment,
    }.merge(faraday_response_log_context(exception)).compact
  end

  def faraday_response_log_context(exception)
    response = exception.respond_to?(:response) ? exception.response : nil
    return {} unless response

    response = response[:response] || response['response'] || response
    body, body_truncated = truncated_backend_response_body(response[:body] || response['body'])

    {
      backend_status: response[:status] || response['status'],
      backend_url: (response[:url] || response['url'])&.to_s,
      backend_response_body: body,
      backend_response_body_truncated: body_truncated,
    }.compact
  end

  def truncated_backend_response_body(body)
    return [nil, nil] if body.nil?

    value = body.is_a?(String) ? body : body.to_json
    return [nil, nil] if value.blank?

    [value.first(500), value.length > 500]
  end

  alias_method :handle_connection_failed, :raise_internal_server_error
  alias_method :handle_timeout_error, :raise_internal_server_error
  alias_method :handle_server_error, :raise_internal_server_error
end
