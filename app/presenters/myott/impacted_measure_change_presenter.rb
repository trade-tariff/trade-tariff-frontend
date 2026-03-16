module Myott
  class ImpactedMeasureChangePresenter < SimpleDelegator
    def initialize(change, trade_direction:)
      super(change)
      @trade_direction = trade_direction
    end

    def change_type
      self['change_type']
    end

    def additional_code
      self['additional_code'].presence || 'N/A'
    end

    def quota_order_number
      self['quota_order_number'].presence || 'N/A'
    end

    def date_of_effect
      Date.parse(self['date_of_effect']).to_fs
    end

    def date_of_effect_visible
      parsed_date_of_effect_visible.to_fs
    end

    def commodity_link_params
      {
        day: parsed_date_of_effect_visible.day,
        month: parsed_date_of_effect_visible.month,
        year: parsed_date_of_effect_visible.year,
        anchor: trade_direction_anchor,
      }
    end

    def trade_direction_anchor
      @trade_direction == 'export' ? 'export' : 'import'
    end

    private

    def parsed_date_of_effect_visible
      @parsed_date_of_effect_visible ||= Date.parse(self['date_of_effect_visible'])
    end
  end
end
