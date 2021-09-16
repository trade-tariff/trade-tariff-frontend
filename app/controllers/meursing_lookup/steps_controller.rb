module MeursingLookup
  class StepsController < ApplicationController
    before_action do
      @no_shared_search = true
      @tariff_last_updated = nil
    end

    include WizardSteps

    self.wizard_class = MeursingLookup::Wizard

    helper_method :back_link

    private

    def step_path(step = params[:id])
      meursing_lookup_step_path(step)
    end

    def wizard_store_key
      :meursing_lookup
    end

    def on_complete(...)
      redirect_to(search_path)
    end

    def set_page_title
      @title = "#{@current_step.title.downcase} step"
    end

    def back_link(step_path)
      view_context.link_to 'Back', step_path
    end
  end
end
