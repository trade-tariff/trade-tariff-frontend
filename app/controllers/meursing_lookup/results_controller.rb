module MeursingLookup
  class ResultsController < ApplicationController
    before_action :set_goods_nomenclature_code

    include GoodsNomenclatureHelper

    def show
      session.delete(Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY)

      redirect_to goods_nomenclature_path
    end

    def create
      meursing_lookup_result.attributes = result_params.slice(:meursing_additional_code_id)

      session[Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY] = meursing_lookup_result.meursing_additional_code_id

      redirect_to goods_nomenclature_path
    end

    private

    def result_params
      params.require(:meursing_lookup_result).permit(:meursing_additional_code_id, :goods_nomenclature_code)
    end

    def set_goods_nomenclature_code
      @goods_nomenclature_code = params[:goods_nomenclature_code] || # Set by the link to show action query param
        result_params[:goods_nomenclature_code] # Set by the update form submission
    end
  end
end
