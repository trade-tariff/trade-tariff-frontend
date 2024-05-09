module GreenLanes
  class CheckMovingRequirementsController < ApplicationController
    before_action :check_moving_requirements

    def start
      @commodity_code = params[:code]
      render 'start'
    end

    def edit
      @commodity_code = params[:code]
      @check_moving_requirements_form = CheckMovingRequirementsForm.new(commodity_code: @commodity_code)

      render 'edit'
    end

    def update
      @check_moving_requirements_form = CheckMovingRequirementsForm.new(check_moving_requirements_params)

      if @check_moving_requirements_form.valid?
        redirect_to result_green_lanes_check_moving_requirements_path
      else
        render 'edit', status: :unprocessable_entity
      end
    end

    private

    def check_moving_requirements_params
      params.require(:check_moving_requirements_form).permit(
        :commodity_code,
        :country_of_origin,
        :moving_date,
      )
    end

    def check_moving_requirements
      unless TradeTariffFrontend.green_lanes_enabled?
        raise TradeTariffFrontend::FeatureUnavailable
      end
    end
  end
end
