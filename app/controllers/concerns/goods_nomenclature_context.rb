module GoodsNomenclatureContext
  extend ActiveSupport::Concern

  VALID_CODE_PATTERN = /\A(?:\d{2}|\d{4}|\d{10}|\d{10}-\d{2})\z/

  included do
    before_action :set_goods_nomenclature_context
  end

  private

  def set_goods_nomenclature_context
    @goods_nomenclature_code = goods_nomenclature_context_param
    return if @goods_nomenclature_code.nil? || @goods_nomenclature_code == ''
    return if @goods_nomenclature_code.is_a?(String) && @goods_nomenclature_code.match?(VALID_CODE_PATTERN)

    render 'errors/not_found', status: :not_found
  end

  def goods_nomenclature_context_param
    params[:goods_nomenclature_code]
  end

  def nested_goods_nomenclature_context_param(key)
    nested_params = params[key]

    nested_params[:goods_nomenclature_code] if nested_params.respond_to?(:permit)
  end
end
