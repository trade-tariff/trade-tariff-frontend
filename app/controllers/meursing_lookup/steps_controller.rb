module MeursingLookup
  class StepsController < ApplicationController
    include GoodsNomenclatureHelper
    include GoodsNomenclatureContext
    include WizardSteps

    prepend_before_action :disable_search_form,
                          :disable_switch_service_banner

    before_action do
      clear_meursing_lookup_session
      store_meursing_lookup_result_on_session
    end

    self.wizard_class = MeursingLookup::Wizard

    private

    def wizard_store_key
      :meursing_lookup
    end

    def step_path(step_id = params[:id])
      meursing_lookup_step_path(step_id, goods_nomenclature_code: current_goods_nomenclature_code)
    end

    def store_meursing_lookup_result_on_session
      session[Result::CURRENT_MEURSING_ADDITIONAL_CODE_KEY] = current_step.meursing_code if current_step.key == MeursingLookup::Steps::End.key
    end

    def clear_meursing_lookup_session
      session.delete(wizard_store_key) if current_step.key == MeursingLookup::Steps::Start.key
    end

    def goods_nomenclature_context_param
      params[:goods_nomenclature_code].presence ||
        nested_goods_nomenclature_context_param(step_param_key)
    end

    def step_param_key
      "#{wizard_store_key}_steps_#{current_step.key}"
    end
  end
end
