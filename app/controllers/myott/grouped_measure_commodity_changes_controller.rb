module Myott
  class GroupedMeasureCommodityChangesController < MycommoditiesController
    def show
      @grouped_measure_commodity_changes = TariffChanges::GroupedMeasureCommodityChange.find(
        params[:id],
        user_id_token,
        options,
      )
    end

    private

    def options
      { as_of: as_of.to_fs(:dashed) }
    end
  end
end
