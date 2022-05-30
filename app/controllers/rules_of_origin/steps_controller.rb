module RulesOfOrigin
  class StepsController < ApplicationController
    default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

    include WizardSteps
    self.wizard_class = RulesOfOrigin::Wizard

    before_action do
      disable_search_form
      disable_last_updated_footnote
      disable_switch_service_banner
    end

    before_action :check_service_hasnt_changed, except: :index

    def index
      initialize_wizard!

      super
    end

    private

    def wizard_store_key
      :rules_of_origin
    end

    def step_path(step_id = params[:id])
      rules_of_origin_step_path(step_id)
    end

    def initialize_wizard!
      wizard_store.purge!
      wizard_store.persist service: TradeTariffFrontend::ServiceChooser.service_name,
                           country_code: params[:country_code],
                           commodity_code: params[:commodity_code]
    end

    def check_service_hasnt_changed
      return if TradeTariffFrontend::ServiceChooser.service_name == wizard_store['service']

      if wizard_store['commodity_code'].present?
        redirect_to commodity_path(wizard_store['commodity_code'],
                                   country: wizard_store['country_code'],
                                   anchor: 'rules-of-origin')
      else
        redirect_to find_commodity_path
      end

      wizard_store.purge!
    end
  end
end
