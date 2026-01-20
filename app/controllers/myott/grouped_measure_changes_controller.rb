module Myott
  class GroupedMeasureChangesController < MycommoditiesController
    def show
      opts = { page: (params[:page].presence || 1).to_i,
               per_page: (params[:per_page].presence || 10).to_i,
               as_of: as_of.to_fs(:dashed) }

      @grouped_measure_changes = TariffChanges::GroupedMeasureChange.find(
        params[:id],
        user_id_token,
        opts,
      )
      @commodity_changes = @grouped_measure_changes.grouped_measure_commodity_changes
    end
  end
end
