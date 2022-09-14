module Changeable
  extend ActiveSupport::Concern

  def changes(query_params = {})
    retries(StandardError) {
      body = self.class.get("#{resource_path}/changes", query_params).body
      data = TariffJsonapiParser.new(body).parse
      data.map do |change_data|
        Change.new(change_data)
      end
    }
  end

  private

  def retries(rescue_error)
    retries ||= 0
    yield if block_given?
  rescue rescue_error
    if retries < Rails.configuration.x.http.max_retry
      retries += 1
      retry
    else
      raise
    end
  end
end
