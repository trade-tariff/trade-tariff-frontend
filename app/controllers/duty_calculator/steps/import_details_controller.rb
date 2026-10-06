module DutyCalculator
  module Steps
    class ImportDetailsController < BaseController
      before_action :redirect_unless_ux_improvements

      def show
        start_new_journey if user_session.commodity_code != commodity_code

        @step = Steps::ImportDetails.new(initial_params)

        # The date is only saved on Continue, so a changed date clears the answers that depend on it.
        validate_commodity_validity!
      rescue Faraday::ResourceNotFound
        add_commodity_unavailable_error
      end

      def create
        @step = Steps::ImportDetails.new(permitted_params)
        return render 'show' unless @step.valid?

        validate_commodity_validity!
        route_details = fetch_route_details
        @step.save!
        user_session.trade_defence = route_details[:trade_defence]
        user_session.zero_mfn_duty = route_details[:zero_mfn_duty]

        redirect_to path_after_save(@step)
      rescue Faraday::ResourceNotFound
        add_commodity_unavailable_error
        render 'show'
      end

      protected

      def path_after_save(step)
        # next_step_path also sets the commodity source for some Northern Ireland routes
        next_step_path = step.next_step_path
        return confirm_path if user_session.return_to_confirm && !step.changed?

        can_return_to_confirm?(next_step_path) && user_session.return_to_confirm ? confirm_path : next_step_path
      end

      private

      def redirect_unless_ux_improvements
        redirect_to import_date_path(request.query_parameters.slice('country', 'day', 'month', 'year').merge(commodity_code:)) unless duty_calculator_ux_improvements?
      end

      def permitted_params
        params.require(:duty_calculator_steps_import_details).permit(
          :'import_date(3i)',
          :'import_date(2i)',
          :'import_date(1i)',
          :import_destination,
          :country_of_origin,
        )
      end

      def initial_params
        {
          'import_date(3i)' => reference_date.day.to_s,
          'import_date(2i)' => reference_date.month.to_s,
          'import_date(1i)' => reference_date.year.to_s,
          'import_destination' => user_session.import_destination || default_import_destination,
          'country_of_origin' => params[:country].presence || user_session.origin_country_code,
        }
      end

      def start_new_journey
        user_session.remove_step_ids(Steps::ImportDetails::DEPENDENT_STEPS)
        user_session.vat_assumed = false
        user_session.return_to_confirm = false
        user_session.commodity_code = commodity_code
        user_session.commodity_source = TradeTariffFrontend::ServiceChooser.service_name
        user_session.referred_service = TradeTariffFrontend::ServiceChooser.service_name
      end

      def default_import_destination
        TradeTariffFrontend::ServiceChooser.xi? ? 'XI' : 'UK'
      end

      def validate_commodity_validity!
        Commodity.find(commodity_code, as_of: @step.import_date)
      end

      def add_commodity_unavailable_error
        @commodity_validity_periods = fetch_validity_periods
        @step.errors.add(:import_date, :commodity_not_available_on_date)
      end

      def fetch_validity_periods
        ValidityPeriod.all(Commodity, commodity_code, as_of: @step.import_date)
      rescue Faraday::ResourceNotFound
        []
      end

      # Trade defence and zero MFN duty decide the Northern Ireland routes.
      # They are looked up for the new answers before anything is saved, so a failed
      # lookup leaves the previous answers in place.
      def fetch_route_details
        return {} unless @step.import_destination == 'XI'
        return {} unless @step.country_of_origin == 'GB' || @step.other_country_of_origin?

        as_of = { 'as_of' => @step.import_date.iso8601 }

        {
          trade_defence: commodity_context_service.call('xi', commodity_code, as_of).trade_defence,
          zero_mfn_duty: commodity_context_service.call('xi', commodity_code, as_of.merge('filter[geographical_area_id]' => @step.country_of_origin)).zero_mfn_duty,
        }
      end

      def reference_date
        @reference_date ||=
          if params[:day].present? && params[:month].present? && params[:year].present?
            Date.new(params[:year].to_i, params[:month].to_i, params[:day].to_i)
          else
            user_session.import_date || Time.zone.today
          end
      rescue ArgumentError
        Time.zone.today
      end
    end
  end
end
