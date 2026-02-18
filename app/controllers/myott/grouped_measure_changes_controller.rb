module Myott
  class GroupedMeasureChangesController < MycommoditiesController
    def show
      @grouped_measure_changes = TariffChanges::GroupedMeasureChange.find(
        params[:id],
        user_id_token,
        options,
      )
      @commodity_changes = @grouped_measure_changes.grouped_measure_commodity_changes
    end

    private

    def options
      { page: params.fetch(:page, 1).to_i,
        per_page: params.fetch(:per_page, 10).to_i,
        as_of: as_of.to_fs(:dashed) }
    end
  end
end
