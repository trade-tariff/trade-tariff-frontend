module DutyCalculator
  module Steps
    class ImportDateController < BaseController
      def show
        @step = Steps::ImportDate.new(initial_date_params)

        persist_commodity_data
      end

      def create
        @step = Steps::ImportDate.new(permitted_params)

        validate(@step)
      end

      private

      def permitted_params
        params.require(:duty_calculator_steps_import_date).permit(
          :'import_date(3i)',
          :'import_date(2i)',
          :'import_date(1i)',
        )
      end

      def initial_date_params
        {
          'import_date(3i)' => day.to_s,
          'import_date(2i)' => month.to_s,
          'import_date(1i)' => year.to_s,
        }
      end

      def persist_commodity_data
        user_session.commodity_code = commodity_code
        user_session.commodity_source = TradeTariffFrontend::ServiceChooser.service_name
        user_session.referred_service = TradeTariffFrontend::ServiceChooser.service_name
        user_session.import_date = @step.import_date.strftime('%Y-%m-%d')
      end

      def day
        params[:day] || now.day
      end

      def month
        params[:month] || now.month
      end

      def year
        params[:year] || now.year
      end

      def now
        @now ||= Time.zone.now
      end
    end
  end
end
