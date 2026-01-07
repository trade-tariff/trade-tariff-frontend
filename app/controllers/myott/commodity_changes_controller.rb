module Myott
  class CommodityChangesController < MycommoditiesController
    def ending
      @change = changes('ending')
    end

    def classification
      @change = changes('classification')
    end

    def changes(id)
      TariffChanges::CommodityChange.find(
        id,
        user_id_token,
        { as_of: as_of.strftime('%Y-%m-%d') },
      )
    end
  end
end
