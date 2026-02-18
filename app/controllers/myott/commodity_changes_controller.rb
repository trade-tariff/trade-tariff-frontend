module Myott
  class CommodityChangesController < MycommoditiesController
    ENDING = 'ending'.freeze
    CLASSIFICATION = 'classification'.freeze

    def ending
      @change = changes(ENDING)
    end

    def classification
      @change = changes(CLASSIFICATION)
    end

    private

    def changes(id)
      TariffChanges::CommodityChange.find(
        id,
        user_id_token,
        options,
      )
    end

    def options
      { as_of: as_of.to_fs(:dashed) }
    end
  end
end
