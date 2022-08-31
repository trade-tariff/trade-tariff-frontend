module RulesOfOrigin
  class StepsController < ApplicationController
    include WizardSteps
    self.wizard_class = RulesOfOrigin::Wizard

    delegate :service_name, to: TradeTariffFrontend::ServiceChooser

    before_action do
      disable_search_form
      disable_last_updated_footnote
      disable_switch_service_banner
    end

    before_action :check_session_data,
                  except: :index,
                  if: -> { params[:id] != 'start' }

    def show
      if params[:id] == 'start'
        redirect_to return_to_commodity_path
      else
        super
      end
    end

    private

    def wizard_store_key
      "rules_of_origin-#{params['commodity']}-#{params['country']}"
    end

    def step_path(step_id = params[:id], ...)
      rules_of_origin_step_path(params['commodity'],
                                params['country'],
                                step_id,
                                ...)
    end

    def check_session_data
      if service_name != wizard_store['service'] ||
          params['commodity'].blank? ||
          params['country'].blank?

        redirect_to return_to_commodity_path
        wizard_store.purge!
      end
    end

    def return_to_commodity_path
      return find_commodity_path if params['commodity'].blank?

      commodity_path(params['commodity'],
                     country: params['country'],
                     anchor: 'rules-of-origin')
    end
    helper_method :return_to_commodity_path
  end
end
