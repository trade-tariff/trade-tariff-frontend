class DataExport
  include AuthenticatableApiEntity

  set_singular_path '/uk/user/subscriptions/:id/data_export'

  attr_accessor :status

  def self.create!(id, token, attributes = {})
    super(id, token, attributes)
  end

  def self.find(subscription_id, export_id, token, opts = {})
    return nil if token.nil? && !Rails.env.development?

    path = "/uk/user/subscriptions/#{subscription_id}/data_export/#{export_id}"
    response = api.get(path, opts, headers(token))
    new(parse_jsonapi(response))
  rescue Faraday::UnauthorizedError
    nil
  end

  def self.download_file(id, export_id, token)
    return nil if token.nil? && !Rails.env.development?

    path = "/uk/user/subscriptions/#{id}/data_export/#{export_id}/download"
    response = api.get(path, {}, headers(token))

    {
      body: response.body,
      filename: response.headers['content-disposition'][/filename="?([^"]*)"?/, 1],
      type: response.headers['content-type'],
    }
  rescue Faraday::UnauthorizedError
    nil
  end
end
