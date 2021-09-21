module MeursingLookup
  class StepsController < ApplicationController
    before_action do
      @no_shared_search = true
      @tariff_last_updated = nil
      clear_meursing_lookup_session
      set_page_title
    end

    include WizardSteps

    self.wizard_class = MeursingLookup::Wizard

    private

    def wizard_store_key
      :meursing_lookup
    end

    def set_page_title
      @title = "Meursing lookup: #{current_step.key}"
    end

    def clear_meursing_lookup_session
      session.delete(wizard_store_key) if current_step.key == 'start'
    end
  end
end
