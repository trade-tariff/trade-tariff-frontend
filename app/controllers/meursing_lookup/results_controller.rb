module MeursingLookup
  class ResultsController < ApplicationController
    include GoodsNomenclatureHelper

    def show
      session.delete(Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY)

      redirect_to goods_nomenclature_path
    end

    def create
      meursing_lookup_result.attributes = result_params

      session[Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY] = meursing_lookup_result.meursing_additional_code_id

      redirect_to goods_nomenclature_path
    end

    private

    def result_params
      params.require(:meursing_lookup_result).permit(:meursing_additional_code_id)
    end
  end
end
