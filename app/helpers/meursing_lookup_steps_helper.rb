module MeursingLookupStepsHelper
  NO_FORM_STEPS = %w[
    start
    end
  ].freeze

  def step_with_form?(step)
    !step.key.in?(NO_FORM_STEPS)
  end

  def page_title_for(step)
    "Meursing lookup: #{step.key}"
  end

  def meursing_back_link
    back_link meursing_lookup_step_path(wizard.previous_key, goods_nomenclature_code: current_goods_nomenclature_code) if wizard.previous_key
  end
end
