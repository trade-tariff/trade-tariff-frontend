module DutyCalculator
  class HomepageImportDetailsController < ::DutyCalculator::ApplicationController
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    before_action :ensure_uk_service
    before_action :ensure_duty_calculator_feature_enabled

    def show = @step = Steps::ImportDetails.new(initial_params)

    def create
      @step = Steps::ImportDetails.new(permitted_params.merge(import_destination: 'UK'))
      return render :show unless @step.valid?

      user_session.remove_step_ids(Steps::ImportDetails::DEPENDENT_STEPS - %w[import_destination country_of_origin])
      @step.save!
      user_session.return_to_confirm = false
      redirect_to what_are_you_importing_path
    end

  private

    def permitted_params
      params.require(:duty_calculator_steps_import_details)
        .permit(:'import_date(3i)', :'import_date(2i)', :'import_date(1i)', :country_of_origin)
    end

    def initial_params
      {
        'import_date(3i)' => reference_date.day.to_s,
        'import_date(2i)' => reference_date.month.to_s,
        'import_date(1i)' => reference_date.year.to_s,
        'import_destination' => 'UK',
        'country_of_origin' => user_session.origin_country_code,
      }
    end

    def reference_date = user_session.import_date || Time.zone.today
  end
end
