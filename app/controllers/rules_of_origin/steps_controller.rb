module RulesOfOrigin
  class StepsController < ApplicationController
    include WizardSteps
    self.wizard_class = RulesOfOrigin::Wizard

    before_action do
      disable_search_form
      disable_last_updated_footnote
      disable_switch_service_banner
    end

    private

    def wizard_store_key
      :rules_of_origin
    end

    def step_path(step_id = params[:id])
      rules_of_origin_step_path(step_id)
    end
  end
end
