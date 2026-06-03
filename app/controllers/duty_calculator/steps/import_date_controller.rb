module DutyCalculator
  module Steps
    class ImportDateController < BaseController
      def show
        @step = Steps::ImportDate.new(initial_date_params)

        persist_commodity_data
        add_commodity_unavailable_error if commodity.nil?
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

      def day
        reference_date_components[0].to_s
      end

      def month
        reference_date_components[1].to_s
      end

      def year
        reference_date_components[2].to_s
      end

      def reference_date_components
        @reference_date_components ||=
          if params[:day].present? && params[:month].present? && params[:year].present?
            [params[:day].to_i, params[:month].to_i, params[:year].to_i]
          elsif user_session.import_date.present?
            d = user_session.import_date
            [d.day, d.month, d.year]
          else
            [now.day, now.month, now.year]
          end
      end

      def now
        @now ||= Time.zone.now
      end
    end
  end
end
