class TradingPartnersController < ApplicationController
  include GoodsNomenclatureHelper

  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_last_updated_footnote

  def show
    @trading_partner = TradingPartner.new(country: params[:country])
  end

  def update
    @trading_partner = TradingPartner.new(trading_partner_params)

    if @trading_partner.valid?
      redirect_to goods_nomenclature_path(
        country: @trading_partner.country,
      )
    elsif should_not_render_errors?
      redirect_to goods_nomenclature_path
    else
      render 'show'
    end
  end

  private

  def should_not_render_errors?
    params[:render_errors] == 'false'
  end

  def trading_partner_params
    params.fetch(:trading_partner, {}).permit(:country)
  end
end
