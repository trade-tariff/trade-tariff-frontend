class GoodsNomenclaturesController < ApplicationController
  rescue_from Faraday::ResourceNotFound, with: :find_relevant_goods_code_or_fallback

  def is_heading_id?
    goods_code_id.ends_with?('000000') && goods_code_id.slice(2, 2) != '00'
  end

  private

  def goods_code_id
    params.fetch(:id, '')
  end

  def find_relevant_goods_code_or_fallback
    @search = Search.new(q: goods_code_id, as_of: @tariff_last_updated)
    results = @search.perform

    if results.exact_match?
      redirect_to url_for(results.to_param.merge(url_options))
    else
      redirect_to sections_url
    end
  end
end
