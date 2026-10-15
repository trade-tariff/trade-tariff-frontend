module DutyCalculator
  module Steps
    class ImportDateController < BaseController
      def show
        redirect_to_import_details
      end

      def create
        @step = Steps::ImportDate.new(permitted_params)
        validate_commodity_validity! if @step.valid?

        validate(@step)
      rescue Faraday::ResourceNotFound
        add_commodity_unavailable_error
        render 'show'
      end

    private

      # Entry point from the commodity page: a new journey starts here.
      def redirect_to_import_details
        user_session.return_to_confirm = false

        redirect_to import_details_path(request.query_parameters.slice('country', 'day', 'month', 'year').merge(commodity_code:))
      end

      def permitted_params
        params.require(:duty_calculator_steps_import_date).permit(
          :'import_date(3i)',
          :'import_date(2i)',
          :'import_date(1i)',
        )
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
    end
  end
end
