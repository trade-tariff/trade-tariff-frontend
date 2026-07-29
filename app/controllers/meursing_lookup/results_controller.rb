module MeursingLookup
  class ResultsController < ApplicationController
    include GoodsNomenclatureHelper
    include GoodsNomenclatureContext

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

    def goods_nomenclature_context_param
      params[:goods_nomenclature_code].presence ||
        nested_goods_nomenclature_context_param(:meursing_lookup_result)
    end
  end
end
