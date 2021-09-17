module MeursingLookup
  class StepsController < ApplicationController
    before_action do
      @no_shared_search = true
      @tariff_last_updated = nil
    end

    include WizardSteps

    self.wizard_class = MeursingLookup::Wizard

    helper_method :back_link, :last_commodity_code

    private

    def step_path(step = params[:id])
      meursing_lookup_step_path(step)
    end

    def wizard_store_key
      :meursing_lookup
    end

    def set_page_title
      @title = "#{@current_step.key} step"
    end

    def back_link(step_path)
      view_context.link_to 'Back', step_path
    end

    def last_commodity_code
      session[:commodity_code]
    end
  end
end
