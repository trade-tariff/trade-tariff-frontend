module Myott
  class GroupedMeasureCommodityChangesController < MycommoditiesController
    before_action :authenticate

    def show
      @grouped_measure_commodity_changes = TariffChanges::GroupedMeasureCommodityChange.find(
        params[:id],
        user_id_token,
        { as_of: as_of.strftime('%Y-%m-%d') },
      )
    end
  end
end
