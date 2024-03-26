module XiOnlyApiEntity
  extend ActiveSupport::Concern
  include ApiEntity

  module ClassMethods
    private

    def api
      # Always use the XI backend because all green lanes data are stored there
      Rails.application.config.http_client_xi
    end
  end
end
