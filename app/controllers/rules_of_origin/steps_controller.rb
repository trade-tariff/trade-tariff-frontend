module RulesOfOrigin
  class StepsController < ApplicationController
    include WizardSteps
    self.wizard_class = RulesOfOrigin::Wizard

    before_action do
      disable_search_form
      disable_last_updated_footnote
      disable_switch_service_banner
    end

    before_action :check_service_hasnt_changed,
                  except: :index,
                  if: -> { params[:id] != wizard_class.steps.first.key }

    def show
      if params[:id] == wizard_class.steps.first.key
        redirect_to return_to_commodity_path
      else
        super
      end
    end

    private

    def wizard_store_key
      :rules_of_origin
    end

    def step_path(step_id = params[:id])
      rules_of_origin_step_path(step_id)
    end

    def check_service_hasnt_changed
      if TradeTariffFrontend::ServiceChooser.service_name != wizard_store['service']
        redirect_to return_to_commodity_path
        wizard_store.purge!
      end
    end

    def return_to_commodity_path
      return find_commodity_path if wizard_store['commodity_code'].blank?

      commodity_path(wizard_store['commodity_code'],
                     country: wizard_store['country_code'],
                     anchor: 'rules-of-origin')
    end
    helper_method :return_to_commodity_path
  end
end
