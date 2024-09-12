module GreenLanes
  module Concerns
    module ExpirableUrl
      extend ActiveSupport::Concern

      URL_EXPIRATION_TIME = 10.hours

      def page_has_not_expired
        return unless params[:t]

        url_initial_time = Time.strptime(params[:t], '%s')

        if url_initial_time < Time.zone.now - URL_EXPIRATION_TIME
          redirect_to green_lanes_start_path
        end
      end
    end
  end
end
