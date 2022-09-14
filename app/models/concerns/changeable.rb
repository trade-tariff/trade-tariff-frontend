require 'retriable'

module Changeable
  extend ActiveSupport::Concern
  include Retriable

  def changes(query_params = {})
    retries(StandardError) do
      body = self.class.get("#{resource_path}/changes", query_params).body
      data = TariffJsonapiParser.new(body).parse
      data.map do |change_data|
        Change.new(change_data)
      end
    end
  end
end
