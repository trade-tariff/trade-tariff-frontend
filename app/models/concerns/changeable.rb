module Changeable
  extend ActiveSupport::Concern

  def changes(query_params = {})
    body = self.class.get("#{resource_path}/changes", query_params).body
    data = TariffJsonapiParser.new(body).parse
    data.map { |change_data| Change.new(change_data) }
  end
end
