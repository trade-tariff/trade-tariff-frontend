class CheckMovingRequirementsController < ApplicationController
  def start
    @commodity_code = params[:code]
    render 'start'
  end

  def edit
    @commodity_code = params[:code]

    @check_moving_requirement = CheckMovingRequirement.new(commodity_code: @commodity_code)
    render 'edit'
  end
end
