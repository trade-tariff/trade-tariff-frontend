class CommoditiesController < ApplicationController
  def show
    @commodity = Commodity.find(params[:id], query_params)
    @heading = @commodity.heading
    @chapter = @commodity.chapter
    @section = @commodity.section
  end

  def edit
    @commodity = Commodity.find(params[:id])
  end

  def update
    @commodity = Commodity.find(params[:id])
    @commodity.update_attrs(params)
    redirect_to edit_commodity_path(@commodity.to_param)
  end
end
