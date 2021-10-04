require 'api_entity'

class MeursingMeasure
  include ApiEntity

  attr_accessor :id,
                :reduction_indicator,
                :formatted_duty_expression

  def self.all_for(root_measure, additional_code_id)
    filter_params = {
      filter: {
        measure_sid: root_measure.id,
        additional_code_id: additional_code_id,
      },
    }

    all(params: filter_params)
  end
end
