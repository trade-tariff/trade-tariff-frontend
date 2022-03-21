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
    else
      render 'show'
    end
  end

  private

  def trading_partner_params
    params.fetch(:trading_partner, {}).permit(:country)
  end
end
