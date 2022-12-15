module UkOnlyApiEntity
  extend ActiveSupport::Concern
  include ApiEntity

  module ClassMethods
    private

    def api
      # Always use the UK backend because all News Items are stored there
      Rails.application.config.http_client_uk
    end
  end
end
