module DutyCalculator
  module Steps
    class PrefillUserSessionController < BaseController
      before_action :update_user_session

      def show
        @step = Steps::Prefill.new

        redirect_to @step.next_step_path
      end

      private

      def user_session
        @user_session ||= UserSession.build_from_params(session, user_session_params)
      end

      def user_session_params
        params.permit(
          :commodity_code,
          :country_of_origin,
          :import_date,
          :import_destination,
          :redirect_to,
        )
      end

      def update_user_session
        user_session.trade_defence = commodity.trade_defence
        user_session.zero_mfn_duty = filtered_commodity(query: commodity_filter).zero_mfn_duty
      end

      def commodity_filter
        country_of_origin = user_session.other_country_of_origin.presence || user_session.country_of_origin

        { 'filter[geographical_area_id]' => country_of_origin }
      end
    end
  end
end
