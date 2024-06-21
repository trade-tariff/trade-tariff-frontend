class TradingPartnersController < ApplicationController
  include GoodsNomenclatureHelper

  before_action :disable_search_form,
                :disable_switch_service_banner,
                :disable_last_updated_footnote,
                :set_goods_nomenclature_code

  def show
    @trading_partner = TradingPartner.new(country: params[:country])
  end

  def update
    @trading_partner = TradingPartner.new(country: trading_partner_params[:country])

    if @trading_partner.valid?
      redirect_to goods_nomenclature_path(
        country: @trading_partner.country,
        anchor: trading_partner_params[:anchor],
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
    params.fetch(:trading_partner, {}).permit(:country, :anchor, :goods_nomenclature_code)
  end

  def set_goods_nomenclature_code
    @goods_nomenclature_code = params[:goods_nomenclature_code] || # Set by the link to show action query param
      trading_partner_params[:goods_nomenclature_code] # Set by the update form submission
  end
end
