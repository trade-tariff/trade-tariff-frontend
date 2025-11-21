module Myott
  class GroupedMeasureChangesController < MycommoditiesController
    before_action :authenticate

    def show
      @grouped_measure_changes = TariffChanges::GroupedMeasureChange.find(
        params[:id],
        user_id_token,
        { as_of: as_of.strftime('%Y-%m-%d') },
      )
    end
  end
end
